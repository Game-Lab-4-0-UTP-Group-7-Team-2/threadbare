extends TextureButton

var clip_id := ""

func _ready():
	clip_id = name  # Usa el nombre del nodo como ID (ej: clip_1)

func _get_drag_data(at_position):
	var preview = duplicate()
	preview.modulate.a = 0.6
	set_drag_preview(preview)
	return clip_id
