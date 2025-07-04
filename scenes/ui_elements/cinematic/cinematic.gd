# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
## Shows a dialogue, then transitions to another scene.
## Intended for use in non-interactive cutscenes, such as the intro and outro to a quest
class_name Cinematic
extends Node2D

## Dialogue for cinematic scene
@export var dialogue: DialogueResource = preload("uid://b7ad8nar1hmfs")

## Animation player, to be used from [member dialogue] (if needed)
@export var animation_player: AnimationPlayer

## Scene to switch to once [member dialogue] is complete
@export_file("*.tscn") var next_scene: String

## Optional path inside [member next_scene] where the player should appear.
@export var spawn_point_path: String


func _ready() -> void:
	DialogueManager.show_dialogue_balloon(dialogue, "", [self])
	await DialogueManager.dialogue_ended

	# 🚫 NO CAMBIAR ESCENA si ya estamos en StealthTemplateLevel
	if get_tree().current_scene.name == "StealthTemplateLevel":
		return

	# ✅ Si hay otra escena y no estamos en StealthTemplateLevel, sí cambia
	if next_scene:
		SceneSwitcher.change_to_file_with_transition(
			next_scene,
			spawn_point_path,
			Transition.Effect.FADE,
			Transition.Effect.FADE,
		)
