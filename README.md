# 地基复制

## Overview

**现在可以记录小木牌上面画的图啦**

看到大佬建的基地好羡慕，但是自己又不会建？
让大佬通过这个Mod把基地复制给你吧。

这个Mod可以让你把基地（包括箱子内的物品，但是包裹和礼物会被记录为空包裹和空礼物）从一个服务器复制到另一个服务器，也可以在同一个服务器内复制基地。注意是这个Mod是单纯复制基地（范围你自己设定）而不是整个地图噢。

当然，前提是你要有管理员权限。

用法: 按Y或者U在聊天窗口输入下面命令。

- `+record`

    你必须在该命令后加上数字作为正方形的边长。比如`+record5`就设定了一个以你的角色为中心的，边长为5个地皮距离的正方形区域。系统会记录下该区域内的所有建筑和植物（不包括树木），还会记录下地皮。

- `+deploy`

    单纯输入`+deploy`即可。系统会自动以你的角色为中心，部署你上次记录的基地连同地皮。

- `+wipe`

    你必须在该命令后加上数字作为正方形的边长。比如`+wipe5`就设定了一个以你的角色为中心的，边长为5个地皮距离的正方形区域。系统会删除该区域内的所有建筑和植物。请慎用这个命令。

另外，请注意，上面所有的以角色为中心，并不是严格意义地以角色为中心，而是以最接近角色的地皮交汇点（就是拿着草叉时地图上显示的格子的十字点上）为中心。

你的基地的数据会被存储在Mod文件夹`mods\workshop-1942653373\data\`下，文件名是`homedata`和`tiledata`。如果你是运行专服(dedicated server)，文件会被储存在专服的Mod文件夹下。你可以把这两个文件发给好友让他也可以复制你宏大基地。

## Changelog

### 版本1.5.6

- 修复旧存档中记录了mod物品而新存档中没有该mod物品而引起的崩溃

### 版本1.5.0

- 现在可以记录小木牌上面画的图啦

### 版本1.4.4

- 增加萤火虫记录

### 版本1.4.3

- 增加远古家具记录

### 版本1.4.2

- 增加盆栽记录

### 版本1.4

- 可以记录箱子内的物品
- 更改基地数据储存位置

## License

Released under the [GNU GENERAL PUBLIC LICENSE](https://www.gnu.org/licenses/gpl-3.0.en.html)