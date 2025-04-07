extends Node

@export var volume: float = 0;

@onready var bg_music = $MusicPlayer

enum SCENE_SET {MENU, LEVEL}
var current_scene = SCENE_SET.MENU

#var hurt = preload("res://assets/audio/PLACEHOLDER-hurt.wav")
#var jump = preload("res://assets/audio/PLACEHOLDER-jump.wav")
#var attack = preload("res://assets/audio/attack.wav")
#var enemy_hit = preload("res://assets/audio/enemy-hit.wav")

var menu = preload("res://Assets/Sounds/Music/GameJam_Depth-Menu_Mix1.1_M1.0.wav")
var level = preload("res://Assets/Sounds/Music/GameJam_Depth_Mix1.0_M1.0.wav")

func play_sfx(sfx_name: String):
	var stream = null
	#if sfx_name == "jump":
		#stream = jump
	#elif sfx_name == "hurt":
		#stream = hurt
	#elif sfx_name == "attack":
		#stream = attack
	#elif sfx_name == "enemy_hit":
		#stream = enemy_hit
	#else:
		#print("Invalid sfx name")
		#return
	
	var asp = AudioStreamPlayer.new()
	asp.volume_db = volume
	asp.stream = stream
	asp.name = "SFX-"+sfx_name
	
	add_child(asp)
	
	asp.play()
	await asp.finished
	asp.queue_free()

func change_music(scene: int):
#TODO find correct position for volume set ->	bg_music.volume_db = volume
	if current_scene != scene:
		if scene == SCENE_SET.MENU:
			bg_music.stream = menu
		elif scene == SCENE_SET.LEVEL:
			bg_music.stream = level
		bg_music.play()
		current_scene = scene
