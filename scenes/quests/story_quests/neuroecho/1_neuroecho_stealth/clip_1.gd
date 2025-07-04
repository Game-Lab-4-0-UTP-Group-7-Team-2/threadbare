extends TextureButton

var is_dragging = false
var offset = Vector2.ZERO

@export var player_path: NodePath
@export var max_drag_distance: float = 100.0

var player_node: Node2D

func _ready():
	player_node = get_node(player_path)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Solo permite arrastrar si el jugador está cerca
			if player_node and global_position.distance_to(player_node.global_position) <= max_drag_distance:
				is_dragging = true
				offset = get_global_mouse_position() - global_position
		else:
			is_dragging = false

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position() - offset
