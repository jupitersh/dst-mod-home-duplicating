if not GLOBAL.TheNet:GetIsServer() then
	return
end

local io = GLOBAL.require("io")
local Vector3 = GLOBAL.Vector3
local SpawnPrefab = GLOBAL.SpawnPrefab

--储存列表到文件
local function list_save(list, file)
	save_file = io.open(MODROOT..file, "w")
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
	load_file = io.open(MODROOT..file, "r")
	for line in load_file:lines() do
		local read_line = {}
		for w in string.gmatch(line,"([^',']+)") do     --按照“,”分割字符串
		    table.insert(read_line, w)
		end
		table.insert(list_from_file, read_line)
	end
	load_file:close()
	for k,v in pairs(list_from_file) do
		print(k)
	end
	return list_from_file
end

--判定哪些物品列入复制的项目
local function ShouldCopy(inst)
	if inst and inst:HasTag("structure") then
		return true
	end
	return false
end

--主函数
local NetworkingSay = GLOBAL.Networking_Say
GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, ...)
	NetworkingSay(guid, userid, name, prefab, message, colour, whisper, ...)
	--保存基地，record的首字母
	if string.sub(message,1,2)=="+r" then
		local player
		for i, v in ipairs(GLOBAL.AllPlayers) do
			if v.userid == userid then
				player = v
			end
		end
		if player ~= nil and player.userid == userid and player.Network:IsServerAdmin() then
			local x, y, z = player.Transform:GetWorldPosition()
			x = math.floor(x/4)*4
			y = 0
			z = math.floor(z/4)*4
			local entity_list = TheSim:FindEntities(x, y, z, 12*3)
			local ents_list = {}
			for i, entity in pairs(entity_list) do
				if ShouldCopy(entity) then
					local pos_in_world = Vector3(entity.Transform:GetWorldPosition())
					local pos_in_relative = Vector3(pos_in_world.x-x, pos_in_world.y-y, pos_in_world.z-z)
					local orient_in_world = entity.Transform:GetRotation()
					local entity_record = {entity.prefab, pos_in_relative.x, pos_in_relative.z, orient_in_world}
					table.insert(ents_list, entity_record)
				end
			end
			list_save(ents_list, "list.txt")
		end
	end
	--部署基地，deploy的首字母
	if string.sub(message,1,2)=="+d" then
		local player
		for i, v in ipairs(GLOBAL.AllPlayers) do
			if v.userid == userid then
				player = v
			end
		end
		if player ~= nil and player.userid == userid and player.Network:IsServerAdmin() then
			local x, y, z = player.Transform:GetWorldPosition()
			x = math.floor(x/4)*4
			y = 0
			z = math.floor(z/4)*4
			local ents_list = list_load("list.txt")				
			for k,v in pairs(ents_list) do
				local ents_prefab = v[1]
				local pos_in_relative = Vector3(v[2],0,v[3])
				local orient_in_world = v[4]
				local pos_in_world = Vector3(pos_in_relative.x+x, pos_in_relative.y+y, pos_in_relative.z+z)

				local tile = TheWorld.Map:GetTileAtPoint(pos_in_world.x, pos_in_world.y, pos_in_world.z) --目标坐标的地皮
				local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255 --判定是否可以再生

				if canspawn then
					local spawn_prefab = SpawnPrefab(ents_prefab)
					spawn_prefab.Transform:SetPosition(pos_in_world:Get())
					spawn_prefab.Transform:SetRotation(orient_in_world)
				end
			end
		end
	end
end