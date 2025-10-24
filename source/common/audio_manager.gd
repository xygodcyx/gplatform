extends Node


var bgm_list: Dictionary[String, AudioStream] = {
    "level": preload("res://assets/audios/level_bgm.wav"),
    "menu": preload("res://assets/audios/menu_bgm.wav"),
}

var sfx_list: Dictionary[String, AudioStream] = {
    "big_egg_collect": preload("res://assets/audios/big_egg_collect.wav"),
    "cancel": preload("res://assets/audios/cancel.wav"),
    "confirm": preload("res://assets/audios/confirm.wav"),
    "fruit_collect": preload("res://assets/audios/fruit_collect.wav"),
    "hit_damage": preload("res://assets/audios/hit_damage.wav"),
}

var bgm_name = ""
var sfx_name = ""
var lister: AudioListener2D
var bgm_asp: AudioStreamPlayer
var bgm_stream: AudioStream

func _ready() -> void:
    init()
    SignalManager.volume_change.connect(
        func(volume):
            bgm_asp.volume_linear = volume / 100
    )
    
    
func init():
    lister = AudioListener2D.new()
    lister.process_mode = Node.ProcessMode.PROCESS_MODE_ALWAYS
    add_child(lister)
    bgm_asp = AudioStreamPlayer.new()
    bgm_asp.process_mode = Node.ProcessMode.PROCESS_MODE_ALWAYS
    bgm_asp.bus = "bgm"
    add_child(bgm_asp)
    bgm_asp.volume_linear = DataManager.volume / 100
    bgm_stream = AudioStream.new()

func play_bgm(bgm: String):
    if (bgm_name == bgm): return
    bgm_name = bgm
    bgm_asp.stream_paused = false
    bgm_asp.stream = bgm_list[bgm]
    bgm_asp.play()

func play_sfx(sfx: String):
    sfx_name = sfx
    var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
    audio_player.process_mode = Node.ProcessMode.PROCESS_MODE_ALWAYS
    audio_player.bus = "sfx"
    audio_player.stream = sfx_list[sfx]
    audio_player.volume_linear = DataManager.volume / 100
    audio_player.finished.connect(
        func():
            audio_player.queue_free()
    )
    add_child(audio_player)
    audio_player.play()

func pause_bgm():
    bgm_asp.stream_paused = true

func play_sfx_big_egg_collect():
    play_sfx("big_egg_collect")

func play_sfx_cancel():
    play_sfx("cancel")

func play_sfx_confirm():
    play_sfx("confirm")

func play_sfx_fruit_collect():
    play_sfx("fruit_collect")

func play_sfx_hit_damage():
    play_sfx("hit_damage")