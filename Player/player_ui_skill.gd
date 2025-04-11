extends Control

@export var icon_image : CompressedTexture2D
@export var btn_info : int
@export var countable : bool
@export var active : bool

@onready var icon : Sprite2D = $Icon
@onready var multLable : Label = $x
@onready var valueLable : Label = $value
@onready var bntInfo : Label = $bntInfo


func _ready():
	icon.texture = icon_image
	bntInfo.text = str(btn_info)

	if countable:
		icon.position.x-=30
		multLable.visible = true
		valueLable.visible = true
		valueLable.text = "0"

func set_label_value(value : String):
	valueLable.text = value

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "skill_cooldown":
		get_node("AnimationPlayer").play("RESET")
