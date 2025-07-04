extends Area2D

@export var next_scene_path : String = "res://scenes/quests/story_quests/neuroecho/juegodememoria/Main.tscn"

func _on_sleep_trap_body_entered(body):
	if body.is_in_group("Player"):
		body.sleep()  # Suponiendo que tienes una función llamada `sleep()` en tu jugador
		await get_tree().create_timer(2.0).timeout  # Espera 2 segundos (opcional)
		get_tree().change_scene_to_file(next_scene_path)
