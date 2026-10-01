# MYFirstGame · Fantasy Knight

> 一个用 **Godot 4.4** 从零手搓的 2D 像素平台跳跃小游戏。踩过的每一个坑都留在代码和注释里了。

![Engine](https://img.shields.io/badge/Godot-4.4-478CBF?logo=godotengine&logoColor=white)
![Language](https://img.shields.io/badge/GDScript-100%25-355570)
![Platform](https://img.shields.io/badge/Platform-Windows%20x86__64-0078D4)
![Status](https://img.shields.io/badge/Status-可通关-orange)

---

## 目录

- [项目简介](#项目简介)
- [游戏玩法](#游戏玩法)
- [操作方式](#操作方式)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [技术实现细节](#技术实现细节)
- [导出发布](#导出发布)
- [已知问题与后续计划](#已知问题与后续计划)

---

## 项目简介

这是我学习 Godot 引擎时做的第一个完整项目——一个横版卷轴平台跳跃游戏。目标是**把 2D 游戏开发的核心机制都亲手实现一遍**，而不是调用现成模板：

- **角色控制**：基于 `CharacterBody2D` 的手感调优（重力、跳跃初速、地面/空中摩擦分离）
- **状态驱动动画**：`AnimatedSprite2D` 按"是否在地面 + 移动方向"切换 idle / run / jump 三组动画，并自动翻转朝向
- **TileMap 关卡**：用 TileSet 手绘地形与背景两层地图
- **两条独立 AI 逻辑**：史莱姆用双 `RayCast2D` 实现"撞墙掉头"巡逻；移动平台用 `AnimationPlayer` 驱动位移
- **完整的死亡-重生闭环**：死亡 → 全局时间缩放慢动作 → 移除碰撞体 → 定时器 → 重载场景
- **音效系统**：分 Master / Music / SFX 三条音频总线，独立调音量

整个项目**不含任何第三方插件或 GDExtension**，纯 GDScript + 引擎内置节点，可以直接打开就跑。

---

## 游戏玩法

| 元素 | 说明 |
|---|---|
| 🧙 **骑士（Player）** | 玩家角色，`CharacterBody2D`，可左右移动、跳跃 |
| 🪙 **金币（Coin）** | 19 枚收集物（主关卡中 7 + 12 枚），吃到后计分 +1，播放拾取动画与音效后消失 |
| 🟢 **史莱姆（Slime）** | 巡逻的敌人，碰到即死。用射线检测边界后自动掉头 |
| 🟫 **平台** | 1 块固定平台 + 3 块动画驱动平台（水平往复、水平长距离平移、垂直升降） |
| ☠️ **Killzone（即死区）** | 掉出地图或触碰敌人时触发死亡流程 |
| 🖥️ **HUD** | 左上角实时显示已收集金币数、操作提示等文字 |

**胜负条件**：本作没有"通关"判定，属于无限循环的街机式玩法——收集尽可能多的金币，掉下去就重新来过。死亡后自动重载场景，分数归零。

---

## 操作方式

| 操作 | 按键 |
|---|---|
| 向左移动 | `A` 或 `←` |
| 向右移动 | `D` 或 `→` |
| 跳跃 | `Space`（空格） |

> 所有按键都在 `project.godot` 的 `[input]` 段里定义成了**输入动作**（`move_left` / `move_right` / `jump`），代码里只引用动作名，不写死键值——想改键位或加手柄支持，改这一处即可。

---

## 快速开始

### 环境要求

- [Godot Engine 4.4](https://godotengine.org/download)（Standard 版即可，本项目用 Forward+ 渲染器）

### 运行步骤

```bash
# 1. 克隆或直接拷贝项目目录
cd "Godot Project/myfirstgame"

# 2. 用 Godot 打开：启动 Godot → Import → 选择本目录的 project.godot
# 3. 按 F5 运行（或点右上角 ▶ 按钮）
```

> `project.godot` 里已把主场景设为 `scenes/game.tscn`，打开后直接 F5 就能玩，无需任何额外配置。
> `.godot/` 目录是引擎自动生成的导入缓存，已在 `.gitignore` 中排除，**不需要**提交到版本库。

---

## 项目结构

```
myfirstgame/
├── project.godot                 # 引擎配置：项目名、主场景、输入映射、自动加载
├── export_presets.cfg            # 导出预设：Windows Desktop x86_64
├── default_bus_layout.tres       # 音频总线布局：Master / Music / SFX
├── icon.svg                      # 项目图标
│
├── scenes/                       # 场景（.tscn）
│   ├── game.tscn                 # ★ 主场景：TileMap 关卡 + 全部实体实例 + HUD
│   ├── player.tscn               # 玩家：AnimatedSprite2D + 圆形碰撞体
│   ├── slime.tscn                # 史莱姆：精灵 + 内置 Killzone + 左右射线
│   ├── coin.tscn                 # 金币：精灵 + AnimationPlayer（拾取动画）+ 音效
│   ├── platform.tscn             # 移动平台：AnimatableBody2D + 单向碰撞
│   ├── killzone.tscn             # 即死区：Area2D + 一次性 Timer
│   ├── background_music.tscn     # BGM 播放器（被设为 Autoload 全局单例）
│   └── music.tscn                # 场景内音乐播放器（备用）
│
├── scripts/                      # 逻辑脚本（.gd）
│   ├── player.gd                 # 玩家移动、跳跃、动画状态机
│   ├── slime.gd                  # 史莱姆巡逻 AI
│   ├── coin.gd                   # 拾取回调 → 通知 GameManager 加分
│   ├── killzone.gd               # 死亡流程：慢动作 → 禁用碰撞 → 重载场景
│   └── gamemanager.gd            # 全局分数管理 + 更新 HUD 文本
│
└── assets/                       # 美术与音频资源
    ├── sprites/                  # knight / slime / coin / platforms / world_tileset
    ├── sounds/                   # jump, coin, hurt, explosion, power_up, tap
    ├── music/                    # time_for_adventure.mp3
    └── fonts/                    # PixelOperator8 点阵字体
```

---

## 技术实现细节

### 角色控制（`scripts/player.gd`）

物理参数与手感设计：

| 参数 | 值 | 说明 |
|---|---|---|
| `SPEED` | `150.0` px/s | 水平移动速度 |
| `JUMP_VELOCITY` | `-300.0` px/s | 跳跃初速度（Y 轴向上为负） |
| `jump.deadzone` | `0.2` | 输入死区 |

```gdscript
# 重力只在离地时累加，落地后不再叠加
if not is_on_floor():
    velocity += get_gravity() * delta

# 跳跃：仅在"刚按下 + 在地面上"时触发，天然防连跳
if Input.is_action_just_pressed("jump") and is_on_floor():
    velocity.y = JUMP_VELOCITY

# 松手后水平速度线性衰减到 0，避免"瞬停"的僵硬感
velocity.x = move_toward(velocity.x, 0, SPEED)
```

**动画状态机**的逻辑是"位置优先、方向其次"：
1. 先判断是否在地面 → 不在则播放 `jump`
2. 在地面时按 `direction` 判断 → 为 `0` 播放 `idle`，否则播放 `run`
3. `direction > 0` 时 `flip_h = false`，`< 0` 时 `flip_h = true`，实现朝向翻转

三组动画均由**精灵图集（AtlasTexture）切割**而成：`idle` 4 帧 @8fps、`run` 16 帧 @9fps、`jump` 单帧。

### 敌人巡逻 AI（`scripts/slime.gd`）

用两条射线做"悬崖/墙壁探测"，命中即掉头——这是最轻量的巡逻方案，不需要寻路系统：

```gdscript
func _process(delta: float) -> void:
    if ray_cast_right.is_colliding():
        animated_sprite_2d.flip_h = true
        direction = -1
    if ray_cast_left.is_colliding():
        animated_sprite_2d.flip_h = false
        direction = 1
    position.x += direction * SPEED * delta   # SPEED = 60
```

> 注释说明：`_process` 每帧运行，这里只做简单的位移与检测，计算量极小，无需放进 `_physics_process`。

### 移动平台（`scenes/game.tscn` + `AnimationPlayer`）

3 块平台各自挂一个 `AnimationPlayer`，用位置关键帧驱动，交给引擎插值，本地方案比手写 `_process` 更平滑也更省代码：

| 平台 | 运动方式 | 关键帧位移 |
|---|---|---|
| `platform2` | 水平往复平移 | `(352, 2)` → `(453, 2)` |
| `platform3` | 水平长距离平移 | `(913, -27)` → `(1010, -27)` |
| `platform4` | 垂直升降 | `(1157, -60)` → `(1157, 5)` |

平台用的是 `AnimatableBody2D` 而非 `StaticBody2D`——**这是关键**：`AnimatableBody2D` 移动时会正确地把站在上面的角色一起带着走。碰撞形状还开启了 `one_way_collision = true`，实现"从下方跳上去可以穿过、从上方落下会站住"的效果。

### 死亡与重生（`scripts/killzone.gd`）

一个完整的"打击感"处理流程：

```gdscript
func _on_body_entered(body: Node2D) -> void:
    print("HHH,NOOB. U DIED! ")
    Engine.time_scale = 0.5                                    # ① 全局慢动作，制造死亡反馈
    body.get_node("CollisionShape2D").queue_free()             # ② 移除碰撞体，防止重复触发
    timer.start()                                              # ③ 启动一次性定时器（0.605s）

func _on_timer_timeout() -> void:
    Engine.time_scale = 1                                      # ④ 恢复时间尺度
    get_tree().reload_current_scene()                          # ⑤ 重载场景 → 满血复活
```

**设计要点**：`Engine.time_scale` 是全局的，必须在重载前恢复成 `1`，否则下一局游戏会一直处于半速状态——这是一个很容易踩的坑。`CollisionShape2D.queue_free()` 则是为了避免角色在死亡慢动作期间持续触发 `body_entered` 信号。

### 节点通信与碰撞层设计

**`GameManager` 作为分数中枢**：`coin.gd` 通过 Godot 4 的**场景唯一节点语法 `%Gamemanager`** 拿到管理器引用（不依赖硬编码路径），调用 `add_point()`；`gamemanager.gd` 负责累加分数并把结果写回 HUD 的 `Label`：

```gdscript
func add_point():
    score += 1
    scorelabel.text = "YOU ATE " + str(score) + "COINS..."
```

**碰撞层（Collision Layer）**：项目只用了两个层，靠 `collision_mask` 精确控制谁能碰到谁，避免误触发——

| 节点 | collision_layer | collision_mask | 含义 |
|---|---|---|---|
| Player | `2` | 默认 | 位于第 2 层，可被金币/即死区检测到 |
| Coin (`Area2D`) | — | `2` | **只**检测第 2 层 → 只有玩家能拾取 |
| Killzone (`Area2D`) | — | `2` | **只**检测第 2 层 → 只有玩家会死，敌人之间互不影响 |

### 音频总线（`default_bus_layout.tres`）

没有把所有声音都丢到 Master 上，而是分了三条总线：

| 总线 | 音量 | 用途 |
|---|---|---|
| `Master` | 0 dB | 总输出 |
| `Music` | **-11.96 dB** | 背景音乐（压低，避免盖住音效） |
| `SFX` | **+0.66 dB** | 音效（略微抬高，保证反馈清晰） |

`background_music.tscn` 被注册为 **Autoload 自动加载**（`project.godot` 的 `[autoload]` 段），因此 BGM 在切换/重载场景时不会中断——这对"死亡即重载场景"的玩法是必需的。

---

## 导出发布

`export_presets.cfg` 中已配置好 Windows 桌面预设，只需补上导出模板：

```
导出目标：Windows Desktop (x86_64)
产物名称：Fantasy Knight
产物路径：../../Fantasy Knight.exe
产物类型：可执行文件 + .pck（embed_pck = false）
脚本模式：script_export_mode = 2（二进制 token 化，源码不裸露）
```

**操作步骤**：`编辑器 → 编辑器菜单 → 管理导出模板` 下载 4.4 对应模板 → `项目 → 导出` → 选择 `Windows Desktop` → 导出。

> 若要发布到其他平台（Web / Android / Linux），在导出面板新增预设即可，代码本身无需改动。

---

## 已知问题与后续计划

这个项目是**学习阶段的第一个成品**，功能完整但不做过度包装。当前明确存在的不足：

**已知问题**

- `gamemanager.gd` 里 `@onready` 用了硬编码相对路径 `$"../TileMapLayers/Labels/Scorelabel"`，而 `coin.gd` 用的是更健壮的 `%Gamemanager` 唯一节点语法——两处风格不统一，前者一旦调整节点层级就会崩
- 死亡逻辑写在 `killzone.gd` 里，玩家和环境共用同一个即死区脚本，职责略有耦合（`print("HHH,NOOB. U DIED! ")` 这条调试输出还留在正式流程里 🙂）
- 没有生命值/复活次数系统，触碰敌人与掉出地图是**同一种**死亡处理，缺少差异化反馈
- 没有暂停菜单、没有开始界面、没有音效音量设置 UI
- `assets/sprites/` 中 `fruit.png`、`slime_purple.png` 以及 `assets/sounds/` 中的 `explosion.wav`、`power_up.wav`、`tap.wav` 是素材包里**尚未被使用**的资源

**后续计划**

- [ ] 引入 `Signal` 全局事件总线，解耦 `coin` / `killzone` / `gamemanager` 之间的直接引用
- [ ] 增加生命值（HP）与无敌帧，区分"受伤"与"掉落即死"
- [ ] 加入暂停菜单（`get_tree().paused`）与音量设置面板
- [ ] 用 `TileMapLayer` 的多层地图做关卡分关，补充第二关地形
- [ ] 接入手柄输入（`InputEventJoypadButton`），验证输入动作抽象层的可扩展性
- [ ] 把死亡调试输出换成正式的死亡动画 + 粒子效果

---

## 补充说明 / 致谢

- 本项目的精灵素材来自公开的像素素材包（**Fantasy Knight** 风格），字体为 PixelOperator8，背景音乐为 `time_for_adventure.mp3`，仅用于个人学习，不用作商业用途。
- 游戏内 HUD 里那句 `I can't use Chinese because...` 是当时的真实吐槽——早期点阵字体不含中文字形，故界面文案统一用英文。若要支持中文，需替换为含中文的字体并在 `project.godot` 中配置 fallback 字体。
- 引擎版本：**Godot 4.4**（`config_version=5`，`Forward Plus` 渲染后端，2D 纹理过滤已设为 Nearest，保证像素画不糊）。
