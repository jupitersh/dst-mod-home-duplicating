if not GLOBAL.TheNet:GetIsServer() then
    return
end

local io = GLOBAL.require("io")
local Vector3 = GLOBAL.Vector3
local SpawnPrefab = GLOBAL.SpawnPrefab
local tonumber = GLOBAL.tonumber
local os = GLOBAL.os
local TheNet = GLOBAL.TheNet
local lang = TheNet:GetDefaultServerLanguage()

local icon_list = {"󰀜","󰀝","󰀞","󰀘","󰀁","󰀟","󰀠","󰀡","󰀂","󰀃","󰀄","󰀅","󰀢","󰀣","󰀇","󰀤","󰀈","󰀙","󰀉","󰀚","󰀊","󰀋","󰀌","󰀍","󰀥","󰀎","󰀏","󰀀","󰀦","󰀐","󰀑","󰀒","󰀧","󰀨","󰀓","󰀔","󰀆","󰀩","󰀪","󰀕","󰀗","󰀫","󰀖","󰀛","󰀬","󰀭","󰀮","󰀯",}
math.randomseed(os.time())
local icon_num = math.random(1,48)

local talkstring = {}
if lang == "zh" then
    talkstring.record = "基地已记录"
    talkstring.deploy = "基地已部署"
    talkstring.wipe = "部署范围已清空"
else
    talkstring.record = "Your Home Has Been Recorded"
    talkstring.deploy = "Your Home Has Been Deployed"
    talkstring.wipe = "The Area Ready for Deploy Has Been Wiped"
end

--储存列表到文件
local function list_save(list, file)
    save_file = io.open(MODROOT.."/data/"..file, "w")
    for k,v in pairs(list) do
        for a,b in pairs(v) do
            save_file:write(b..",")
        end
        save_file:write("\n")
    end
    save_file:close()
end

--从文件读取列表
local function list_load(file)
    local list_from_file = {}
    load_file = io.open(MODROOT.."/data/"..file, "r")
    for line in load_file:lines() do
        local read_line = {}
        for w in string.gmatch(line,"([^',']+)") do     --按照“,”分割字符串
            table.insert(read_line, w)
        end
        table.insert(list_from_file, read_line)
    end
    load_file:close()
    return list_from_file
end

--判定哪些物品列入复制的项目
local function ShouldCopy(inst)
    if inst then
        if inst:HasTag("structure")
        or inst:HasTag("wall")
        or inst:HasTag("flower")
        or inst:HasTag("telebase")
        or inst:HasTag("heavy")
        or inst:HasTag("eyeturret")
        or inst:HasTag("sign")
        or inst.prefab == "grass"
        or inst.prefab == "sapling"
        or inst.prefab == "rock_avocado_bush"
        or inst.prefab == "berrybush"
        or inst.prefab == "berrybush2"
        or inst.prefab == "berrybush_juicy"
        then
            return true
        end
    end
    return false
end

--判断物品是否在范围内
local function InRange(inst,x,z,length)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local length =length*4
    if pos.x>=x-length/2 and pos.x<=x+length/2 and pos.z>=z-length/2 and pos.z<=z+length then
        return true
    end
    return false
end

--判断是否可生成地皮
local function CanTurf(pt)
    local ground = GLOBAL.GetWorld()
    if ground then
        local tile = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
        return tile ~= GLOBAL.GROUND.IMPASSIBLE and tile < GLOBAL.GROUND.UNDERGROUND --and not ground.Map:IsWater(tile)
    end
    return false
end

--生成地皮
local function SpawnTurf(turf, pt)   
    local ground = GLOBAL.GetWorld()
    if ground and CanTurf(pt) then
        local original_tile_type = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
        local x, y = ground.Map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z)
        if x and y then
            ground.Map:SetTile(x, y, turf)
            ground.Map:RebuildLayer(original_tile_type, x, y)
            ground.Map:RebuildLayer(turf, x, y)
        end
        local minimap = TheSim:FindFirstEntityWithTag("minimap")
        if minimap then
            minimap.MiniMap:RebuildLayer(original_tile_type, x, y)
            minimap.MiniMap:RebuildLayer(turf, x, y)
        end
    end
end

--判定哪些物品要清理
local function ShouldRemove(inst)
    if (inst.components.inventoryitem and inst.components.inventoryitem.owner == nil) --排除人物身上的物品
    or inst:HasTag("structure")
    or (inst.components.burnable ~= nil and not inst:HasTag("player")) --包括所有可燃的，因玩家也可燃，故需排除
    or inst:HasTag("boulder") --石矿
    or inst.prefab == "rabbithole" --兔子洞
    then
        return true
    end
    return false
end

--主函数
local NetworkingSay = GLOBAL.Networking_Say
GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, ...)
    NetworkingSay(guid, userid, name, prefab, message, colour, whisper, ...)
    --保存，范围为正方形，以人为中心，后面带参数为边长，单位为大格
    if string.sub(message,1,7)=="+record" and string.len(message) >= 8 and tonumber(string.sub(message,8,-1)) ~= nil then
        local player
        for i, v in ipairs(GLOBAL.AllPlayers) do
            if v.userid == userid then
                player = v
            end
        end
        if player ~= nil and player.userid == userid and player.Network:IsServerAdmin() then
            local x, y, z = player.Transform:GetWorldPosition()
            x = math.floor(x/4+0.5)*4
            y = 0
            z = math.floor(z/4+0.5)*4
            --基地
            local length = tonumber(string.sub(message,8,-1))
            local ents_list = {}
            for i, entity in pairs(GLOBAL.Ents) do
                if ShouldCopy(entity) and InRange(entity, x, z, length) then
                    local pos_in_world = Vector3(entity.Transform:GetWorldPosition())
                    local pos_in_relative = Vector3(pos_in_world.x-x, pos_in_world.y-y, pos_in_world.z-z)
                    local orient_in_world = entity.Transform:GetRotation()
                    local entity_record = {entity.prefab, pos_in_relative.x, pos_in_relative.z, orient_in_world}
                    --判断箱子内物品
                    if entity.components.container then
                        local chest = entity.components.container
                        if not chest:IsEmpty() then
                            for k,v in pairs(chest.slots) do
                                if v:IsValid() and v.persists then
                                    table.insert(entity_record, v.prefab)
                                end
                            end
                        end
                    end
                    table.insert(ents_list, entity_record)
                end
            end
            list_save(ents_list, "homedata")
            --地皮
            local turf_list = {}
            local turf_style = {}

            for i= (x/4-length+0.5)*4, (x/4+length-0.5)*4, 4 do
                for j = (z/4-length+0.5)*4, (z/4+length-0.5)*4, 4 do
                    if CanTurf(Vector3(i, 0, j)) then
                        local tile = GLOBAL.TheWorld.Map:GetTileAtPoint(i, 0, j)
                        local pos_in_world = Vector3(i, 0, j)
                        local pos_in_relative = Vector3(pos_in_world.x-x, pos_in_world.y-y, pos_in_world.z-z)
                        turf_style = {tile, pos_in_relative.x, pos_in_relative.z}
                        table.insert(turf_list, turf_style)
                    end
                end
            end
            list_save(turf_list, "tiledata")
        end
        --执行命令后人物说话提示
        player.components.talker:Say(icon_list[icon_num]..talkstring.record..icon_list[icon_num+1],10,true,true,false)
    end

    --部署，范围为正方形，以人为中心
    if string.sub(message,1,7)=="+deploy" and string.len(message) == 7 then
        local player
        for i, v in ipairs(GLOBAL.AllPlayers) do
            if v.userid == userid then
                player = v
            end
        end
        if player ~= nil and player.userid == userid and player.Network:IsServerAdmin() then
            local x, y, z = player.Transform:GetWorldPosition()
            x = math.floor(x/4+0.5)*4
            y = 0
            z = math.floor(z/4+0.5)*4
            --基地
            local ents_list = list_load("homedata")                
            for k,v in pairs(ents_list) do
                local ents_prefab = v[1]
                local pos_in_relative = Vector3(v[2],0,v[3])
                local orient_in_world = v[4]
                local pos_in_world = Vector3(pos_in_relative.x+x, pos_in_relative.y+y, pos_in_relative.z+z)

                local canspawn = CanTurf(pos_in_world) --判定是否可以再生

                if canspawn then
                    local spawn_prefab = SpawnPrefab(ents_prefab)
                    spawn_prefab.Transform:SetPosition(pos_in_world:Get())
                    spawn_prefab.Transform:SetRotation(orient_in_world)
                    if spawn_prefab.components.container then
                        for i,prefab in pairs(v) do
                            if i >= 5 then
                                spawn_prefab.components.container:GiveItem(GLOBAL.SpawnPrefab(prefab))
                            end
                        end
                    end
                end
            end
            --地皮
            local turf_list = list_load("tiledata")
            local tile_num
            for k,v in pairs(turf_list) do
                tile_num = v[1]
                local pos_in_relative = Vector3(v[2],0,v[3])
                local pos_in_world = Vector3(pos_in_relative.x+x, pos_in_relative.y+y, pos_in_relative.z+z)
                SpawnTurf(tile_num, pos_in_world)
            end
        end
        --执行命令后人物说话提示
        player.components.talker:Say(icon_list[icon_num]..talkstring.deploy..icon_list[icon_num+1],10,true,true,false)
    end

    --删除范围内物品，范围为正方形，以人为中心，后面带参数为边长，单位为大格
    if string.sub(message,1,5)=="+wipe" and string.len(message) >= 6 and tonumber(string.sub(message,6,-1)) ~= nil then
        local player
        for i, v in ipairs(GLOBAL.AllPlayers) do
            if v.userid == userid then
                player = v
            end
        end
        if player ~= nil and player.userid == userid and player.Network:IsServerAdmin() then
            local x, y, z = player.Transform:GetWorldPosition()
            x = math.floor(x/4+0.5)*4
            y = 0
            z = math.floor(z/4+0.5)*4

            local length = tonumber(string.sub(message,6,-1))
            for i, entity in pairs(GLOBAL.Ents) do
                if ShouldRemove(entity) and InRange(entity, x, z, length) then
                    entity:Remove()
                end
            end
        end
        --执行命令后人物说话提示
        player.components.talker:Say(icon_list[icon_num]..talkstring.wipe..icon_list[icon_num+1],10,true,true,false)
    end
end