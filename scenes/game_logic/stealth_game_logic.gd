extends Node

var orden_correcto: Array[String] = ["clip1", "clip2", "clip3", "clip4", "clip5"]

func verificar_orden() -> void:
	var linea_tiempo: HBoxContainer = get_node("../TileMapLayers/TimelineContainer")
	var respuesta: Array[String] = []

	for slot in linea_tiempo.get_children():
		if slot.get_child_count() > 0:
			var hijo: TextureButton = slot.get_child(0) as TextureButton
			respuesta.append(hijo.name)
		else:
			respuesta.append("vacio")

	if respuesta == orden_correcto:
		mostrar_resultado("✅ ¡Memoria reconstruida correctamente!", Color(0, 1, 0))
	else:
		mostrar_resultado("❌ Memoria distorsionada...", Color(1, 0, 0))


func mostrar_resultado(texto: String, color: Color) -> void:
	if has_node("../TileMapLayers/ResultadoLabel"):
		var label: Label = get_node("../TileMapLayers/ResultadoLabel") as Label
		label.text = texto
		label.modulate = color


func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	pass # Replace with function body.
