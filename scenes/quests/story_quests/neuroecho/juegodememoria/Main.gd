extends Node2D

@onready var card_grid = $CenterContainer/CardGrid
@onready var cuenta_regresiva = $CuentaRegresiva
@onready var timer_label = $TimerLabel
@onready var alarma = $Alarma
@onready var boton_reintentar = $UIBoton/BotonReintentar
@onready var label_ganaste = $UIVictory/LabelGanaste

var flipped_cards = []
var total_pairs = 4  # 4 pares = 8 cartas
var tiempo_restante = 15  # segundos

func _ready():
	randomize()
	_init_timer()
	crear_cartas()

func _init_timer():
	cuenta_regresiva.timeout.connect(_on_cuenta_regresiva_timeout)
	cuenta_regresiva.start()

	# Mostrar el tiempo desde el inicio
	timer_label.visible = true
	timer_label.text = str(tiempo_restante)

	# Ocultar elementos al comenzar
	label_ganaste.visible = false
	boton_reintentar.visible = false

func crear_cartas():
	var ids = []
	for i in range(1, total_pairs + 1):
		ids.append_array([i, i])
	ids.shuffle()

	var textures = {
		1: load("res://assets/imagenes/card_1.jpg"),
		2: load("res://assets/imagenes/card_2.jpg"),
		3: load("res://assets/imagenes/card_3.jpg"),
		4: load("res://assets/imagenes/card_4.jpg"),
	}

	var back_texture = load("res://assets/imagenes/TarjetaBase.png")

	for id in ids:
		var card = preload("res://scenes/quests/story_quests/neuroecho/juegodememoria/Card.tscn").instantiate()
		card.id = id
		card.front_texture = textures[id]
		card.back_texture = back_texture
		card.connect("card_flipped", _on_card_flipped)
		card_grid.add_child(card)

func _on_cuenta_regresiva_timeout():
	tiempo_restante -= 1
	timer_label.text = str(tiempo_restante)

	if tiempo_restante > 0 and tiempo_restante % 2 == 0:
		alarma.play()

	if tiempo_restante <= 0:
		cuenta_regresiva.stop()
		timer_label.text = "¡Tiempo agotado!"
		deshabilitar_cartas()
		label_ganaste.visible = false
		boton_reintentar.visible = true

func deshabilitar_cartas():
	for card in card_grid.get_children():
		card.disabled = true

func _on_card_flipped(card):
	if flipped_cards.has(card) or card.is_paired:
		return

	flipped_cards.append(card)

	if flipped_cards.size() == 2:
		if flipped_cards[0].id == flipped_cards[1].id:
			for c in flipped_cards:
				c.set_paired(true)
			flipped_cards.clear()

			# Verificar si ya ganaste
			if card_grid.get_children().all(func(c): return c.is_paired):
				label_ganaste.visible = true
				cuenta_regresiva.stop()
				boton_reintentar.visible = false  # No mostrar botón si ganaste
		else:
			await get_tree().create_timer(1.0).timeout
			for c in flipped_cards:
				c.flip_back()
			flipped_cards.clear()

func _on_boton_reintentar_pressed():
	get_tree().reload_current_scene()
