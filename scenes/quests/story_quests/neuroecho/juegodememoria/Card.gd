extends Button
class_name Card

signal card_flipped(card)

var id = 0
var is_flipped = false
var is_paired = false
var front_texture : Texture
var back_texture : Texture

@onready var image = $Image

func _ready():
	image.texture = back_texture
	connect("pressed", _on_pressed)

func _on_pressed():
	if is_flipped or is_paired:
		return
	flip()

func flip():
	is_flipped = true
	image.texture = front_texture
	emit_signal("card_flipped", self)

func flip_back():
	if not is_paired:
		is_flipped = false
		image.texture = back_texture

func set_paired(p: bool):
	is_paired = p
