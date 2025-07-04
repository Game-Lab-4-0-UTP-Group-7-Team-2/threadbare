class_name Player
extends CharacterBody2D

signal mode_changed(mode: Mode)

enum Mode {
	COZY,
	FIGHTING,
	DEFEATED,
}

const REQUIRED_ANIMATION_FRAMES: Dictionary[StringName, int] = {
	&"idle": 10,
	&"walk": 6,
	&"attack_01": 4,
	&"defeated": 11,
}
const DEFAULT_SPRITE_FRAME: SpriteFrames = preload("uid://vwf8e1v8brdp")

@export var player_name: String = "Player Name"
@export var mode: Mode = Mode.COZY:
	set = _set_mode
@export_range(10, 100000, 10) var walk_speed: float = 300.0
@export_range(10, 100000, 10) var run_speed: float = 500.0
@export_range(10, 100000, 10) var stopping_step: float = 1500.0
@export_range(10, 100000, 10) var moving_step: float = 4000.0
@export var sprite_frames: SpriteFrames = DEFAULT_SPRITE_FRAME:
	set = _set_sprite_frames

@export_group("Sounds")
@export var walk_sound_stream: AudioStream = preload("uid://cx6jv2cflrmqu"):
	set = _set_walk_sound_stream

var input_vector: Vector2

@onready var player_interaction: PlayerInteraction = %PlayerInteraction
@onready var player_fighting: Node2D = %PlayerFighting
@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var _walk_sound: AudioStreamPlayer2D = %WalkSound

# 🧩 Minijuego
@onready var clips_container := $"../ClipsContainer"
@onready var timeline_container := $"../TimelineContainer"
@onready var resultado_label := $"../Resultado Label"
@onready var timer := $Timer

var dragging_clip: Control = null
var offset: Vector2 = Vector2.ZERO
var correct_order: Array[String] = ["clip1", "clip2", "clip3", "clip4", "clip5"]


func _ready() -> void:
	_set_mode(mode)
	_set_sprite_frames(sprite_frames)

	# Comprobación de Timer
	if timer != null:
		timer.wait_time = 60
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)
		timer.start()
	else:
		push_error("❌ Timer no encontrado en el nodo Player.")

func _set_mode(new_mode: Mode) -> void:
	var previous_mode: Mode = mode
	mode = new_mode
	if not is_node_ready():
		return
	match mode:
		Mode.COZY:
			_toggle_player_behavior(player_interaction, true)
			_toggle_player_behavior(player_fighting, false)
		Mode.FIGHTING:
			_toggle_player_behavior(player_interaction, false)
			_toggle_player_behavior(player_fighting, true)
		Mode.DEFEATED:
			_toggle_player_behavior(player_interaction, false)
			_toggle_player_behavior(player_fighting, false)
	if mode != previous_mode:
		mode_changed.emit(mode)

func _set_sprite_frames(new_sprite_frames: SpriteFrames) -> void:
	sprite_frames = new_sprite_frames
	if not is_node_ready():
		return
	if new_sprite_frames == null:
		new_sprite_frames = DEFAULT_SPRITE_FRAME
	player_sprite.sprite_frames = new_sprite_frames
	update_configuration_warnings()

func _toggle_player_behavior(behavior_node: Node2D, is_active: bool) -> void:
	behavior_node.visible = is_active
	behavior_node.process_mode = (
		ProcessMode.PROCESS_MODE_INHERIT if is_active else ProcessMode.PROCESS_MODE_DISABLED
	)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	for animation in REQUIRED_ANIMATION_FRAMES:
		if not sprite_frames.has_animation(animation):
			warnings.append("sprite_frames is missing animation: %s" % animation)
		elif sprite_frames.get_frame_count(animation) != REQUIRED_ANIMATION_FRAMES[animation]:
			warnings.append("sprite_frames animation %s has %d frames, should be %d" % [
				animation,
				sprite_frames.get_frame_count(animation),
				REQUIRED_ANIMATION_FRAMES[animation]
			])
	return warnings

func _set_walk_sound_stream(new_value: AudioStream) -> void:
	walk_sound_stream = new_value
	if not is_node_ready():
		await ready
	if _walk_sound:
		_walk_sound.stream = walk_sound_stream

func _unhandled_input(event: InputEvent) -> void:
	var axis: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_vector = axis * (run_speed if Input.is_action_pressed("running") else walk_speed)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			for clip in clips_container.get_children():
				if clip.get_global_rect().has_point(event.global_position):
					dragging_clip = clip
					offset = clip.global_position - event.global_position
					break
		else:
			if dragging_clip:
				_check_clip_placement()
				dragging_clip = null

func _process(delta: float) -> void:
	
	if Engine.is_editor_hint():
		return

	if player_interaction.is_interacting or mode == Mode.DEFEATED:
		velocity = Vector2.ZERO
	else:
		var step: float = stopping_step if input_vector.is_zero_approx() else moving_step
		velocity = velocity.move_toward(input_vector, step * delta)
		move_and_slide()

	if dragging_clip:
		dragging_clip.global_position = get_global_mouse_position() + offset

func is_running() -> bool:
	return input_vector.length_squared() > (walk_speed * walk_speed) + 1.0

func teleport_to(tele_position: Vector2, smooth_camera := false, look_side := Enums.LookAtSide.UNSPECIFIED) -> void:
	var camera := get_viewport().get_camera_2d()
	if is_instance_valid(camera):
		var smoothing_was_enabled: bool = camera.position_smoothing_enabled
		camera.position_smoothing_enabled = smooth_camera
		global_position = tele_position
		%PlayerSprite.look_at_side(look_side)
		await get_tree().process_frame
		camera.position_smoothing_enabled = smoothing_was_enabled
	else:
		global_position = tele_position

func _check_clip_placement() -> void:
	if not timeline_container or not clips_container or not resultado_label:
		return

	var current_order: Array[String] = []
	for slot in timeline_container.get_children():
		var matched: bool = false
		for clip in clips_container.get_children():
			if clip.get_global_rect().intersects(slot.get_global_rect()):
				current_order.append(clip.name)
				matched = true
				break
		if not matched:
			current_order.append("")  # Asegura que cada slot tenga posición, aunque esté vacío

	if current_order == correct_order:
		resultado_label.text = "¡Correcto!"
		if timer:
			timer.stop()
	else:
		resultado_label.text = "Inténtalo de nuevo"

func _on_timer_timeout() -> void:
	if resultado_label:
		resultado_label.text = "¡Tiempo agotado!"


var is_asleep = false

func sleep():
	is_asleep = true
	velocity = Vector2.ZERO
	print("Me estoy quedando dormido... 💤")
