extends Control

@export var icon_image : CompressedTexture2D
@export var countable : bool
@export var active : bool


@onready var icon : Sprite2D = $Icon
@onready var multLable : Label = $x
@onready var valueLable : Label = $value


func _ready():
	icon.texture = icon_image
	if countable:
		icon.position.x-=30
		multLable.visible = true
		valueLable.visible = true
		valueLable.text = "0"

func set_label_value(value : String):
	valueLable.text = value
