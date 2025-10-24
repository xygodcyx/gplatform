# 项目核心功能

## 回放系统

### 前置要求

要想实现回放，就要把玩家的操作抽象出来，因为用的是godot，所以把每个操作都用信号来接收和触发，比如移动、跳跃、下落等，游玩时在input_manager里emit，在玩家里connect，这样我们想模拟玩家跳跃只需要手动emit响应的操作信号就行了，比如：

`input_manager.gd`:

```c
func _process(_delta) -> void:
 if !DataManager.is_in_game || DataManager.is_replaying: return
 if Input.is_action_just_pressed("ui_down"):
  DataManager.append_playback("ui_down")
  SignalManager.down.emit()
 if Input.is_action_just_pressed("jump"):
  DataManager.append_playback("jump")
  SignalManager.jump_start.emit()
 if Input.is_action_just_pressed("jump"):
  SignalManager.jump_end.emit()

 var move_direction = Input.get_axis("ui_left", "ui_right")

 if move_direction < 0.0:
  DataManager.append_playback("ui_left")
 elif move_direction > 0.0:
  DataManager.append_playback("ui_right")
 else:
  if last_move_direction < 0.0:
   DataManager.append_playback("ui_left", false)
  elif last_move_direction > 0.0:
   DataManager.append_playback("ui_right", false)
 last_move_direction = move_direction

 SignalManager.move_direction.emit(move_direction)
```

`player.gd` :

```c

 SignalManager.move_direction.connect(
  func(direction):
   move_direction = direction
 )

 SignalManager.down.connect(
  func():
   is_down = true
 )

 SignalManager.jump_start.connect(
  func():
   is_jump = true
 )

```

### 核心原理

假设你的玩家已经可以根据这些信号实现基本的移动、跳跃和下落等基本功能了，那么就可以来实现回放功能了：

核心原理：

***将玩家的一系列操作用一定的数据结构存放在某个地方，然后在回放的时候以每帧为周期将各种操作取出来执行***

这样我们要考虑的就只有如何保证能完全按正确的顺序取出操作，而一旦正确取出操作并正确执行，那么游戏中发生的一切我们都不用考虑，因为在这种实现模式下，回放时和实际游玩时对游戏中各种实体造成的各种影响没有任何区别，该发生啥就发生啥，唯一需要注意的是如果你的游戏中有随机数，比如暴击、闪避、随机生成物品等，那么你在生成随机数时一定要使用种子随机数，即种子相同随机数就相同，在回放时带上这个种子即可，这样回放时也可以保证随机数与实际游玩时相同了

至于如何**保证能完全按正确的顺序取出操作**，我的想法是手动维护一个game_frame字段，在_process中每帧+=1，在游戏重新时重置为0，往储存操作数组(记为actions)里push_back操作对象时带上操作的名字比如jump和当前帧数比如10，那么在回放时遍历actions时只需要找到帧数与game_frame相同的操作对象即可

我的实现方式（伪代码）：

```c
func find_cur_index(data: Array):
  var n = data.size()
  for i in range(0, n):
    var item = data[i]
    if typeof(item) != TYPE_DICTIONARY:
      continue
    var frame := int(item.get("frame", -1))
    if frame < 0:
      continue
    if frame == game_frame:
      return i
  return -1
```

```c
 var cur_index = find_cur_index(level_playback["playback"])
  var item = level_playback["playback"][cur_index]
  match item.action:
    "ui_left":
      if item.pressed:
        SignalManager.move_direction.emit(-1)
      else:
        SignalManager.move_direction.emit(0)
    "ui_right":
      if item.pressed:
        SignalManager.move_direction.emit(1)
      else:
        SignalManager.move_direction.emit(0)
    "jump":
      if item.pressed:
        SignalManager.jump_start.emit()
    "ui_down":
      if item.pressed:
        SignalManager.down.emit()
```

该项目已在github上开源，大家感兴趣的话可以自行查看游戏源代码：[gplatform](https://github.com/xygodcyx/gplatform)

![preview](/assets/有意思的游戏功能-1/preview.gif)

可以看到只记录操作就可以实现基本的回放，基于此还可以实时展示进行的操作，显得非常“高级”
