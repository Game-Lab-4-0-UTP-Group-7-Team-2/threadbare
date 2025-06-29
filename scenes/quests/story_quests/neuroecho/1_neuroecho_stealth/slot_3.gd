extends Panel

var clip_colocado: Node = null


func can_drop_data(pos, data):
	return true

func drop_data(pos, data):
	# Si ya había un clip, lo borramos
	if clip_colocado:
		clip_colocado.queue_free()

	# Creamos un nuevo botón con el nombre del clip
	var nuevo_clip = TextureButton.new()
	nuevo_clip.name = data
	nuevo_clip.text = data  # También puedes asignar textura si prefieres
	nuevo_clip.disabled = true
	add_child(nuevo_clip)

	clip_colocado = nuevo_clip
