extends Node2D

var player: CharacterBody2D
var opponents: Array[CharacterBody2D] = []

var position_label: Label
var speed_label: Label
var boost_label: Label
var countdown_label: Label

var race_started := false
var race_finished := false

const TRACK_LEFT := 150.0
const TRACK_RIGHT := 1000.0

# Very long race
const TRACK_TOP := -12000.0
const TRACK_BOTTOM := 650.0
const FINISH_Y := -11500.0

# Your textures
const ROAD_TEXTURE := preload("res://assets/texture/road.png")
const GRASS_TEXTURE := preload("res://assets/texture/grass.png")
const CAR_TEXTURE := preload("res://assets/characters/player_car.png")


func _ready() -> void:
	create_grass()
	create_road()
	create_road_edges()
	create_finish_line()
	create_player()
	create_opponents()
	create_boost_pads()
	create_obstacles()
	create_hud()
	start_countdown()


func _physics_process(_delta: float) -> void:
	if race_started and not race_finished:
		move_opponents()
		check_finish()

	update_hud()


# =========================================================
# GRASS
# =========================================================

func create_grass() -> void:
	var grass := TextureRect.new()

	grass.name = "Grass"

	grass.position = Vector2(
		-500,
		TRACK_TOP - 500
	)

	grass.size = Vector2(
		2000,
		TRACK_BOTTOM - TRACK_TOP + 1000
	)

	grass.texture = GRASS_TEXTURE

	grass.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	grass.stretch_mode = TextureRect.STRETCH_TILE

	grass.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(grass)
	move_child(grass, 0)


# =========================================================
# ROAD
# =========================================================

func create_road() -> void:
	var road := TextureRect.new()

	road.name = "Road"

	road.position = Vector2(
		TRACK_LEFT,
		TRACK_TOP
	)

	road.size = Vector2(
		TRACK_RIGHT - TRACK_LEFT,
		TRACK_BOTTOM - TRACK_TOP
	)

	road.texture = ROAD_TEXTURE

	road.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	road.stretch_mode = TextureRect.STRETCH_TILE

	road.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(road)


func create_road_edges() -> void:
	var left_line := Line2D.new()

	left_line.width = 10
	left_line.points = PackedVector2Array([
		Vector2(TRACK_LEFT, TRACK_TOP),
		Vector2(TRACK_LEFT, TRACK_BOTTOM)
	])

	left_line.default_color = Color.WHITE

	add_child(left_line)


	var right_line := Line2D.new()

	right_line.width = 10
	right_line.points = PackedVector2Array([
		Vector2(TRACK_RIGHT, TRACK_TOP),
		Vector2(TRACK_RIGHT, TRACK_BOTTOM)
	])

	right_line.default_color = Color.WHITE

	add_child(right_line)


# =========================================================
# FINISH LINE
# =========================================================

func create_finish_line() -> void:
	var finish := ColorRect.new()

	finish.name = "FinishLine"

	finish.position = Vector2(
		TRACK_LEFT,
		FINISH_Y
	)

	finish.size = Vector2(
		TRACK_RIGHT - TRACK_LEFT,
		70
	)

	finish.color = Color.WHITE

	finish.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(finish)

	for x in range(
		int(TRACK_LEFT),
		int(TRACK_RIGHT),
		60
	):
		var square := ColorRect.new()

		square.position = Vector2(
			x,
			FINISH_Y
		)

		square.size = Vector2(
			30,
			35
		)

		square.color = Color("#222222")

		square.mouse_filter = Control.MOUSE_FILTER_IGNORE

		add_child(square)


# =========================================================
# PLAYER
# =========================================================

func create_player() -> void:
	player = CharacterBody2D.new()

	player.name = "Player"
	player.position = Vector2(575, 500)

	player.set_script(
		load("res://scripts/player.gd")
	)

	add_child(player)


	# Collision
	var collision := CollisionShape2D.new()

	var shape := RectangleShape2D.new()

	shape.size = Vector2(
		55,
		95
	)

	collision.shape = shape

	player.add_child(collision)


	# YOUR CAR IMAGE
	var sprite := Sprite2D.new()

	sprite.name = "CarSprite"

	sprite.texture = CAR_TEXTURE

	sprite.rotation_degrees = 180

	sprite.scale = Vector2(
		0.12,
		0.12
	)

	player.add_child(sprite)


	# Boost flame
	var flame := Polygon2D.new()

	flame.name = "BoostFlame"

	flame.polygon = PackedVector2Array([
		Vector2(-12, 42),
		Vector2(0, 75),
		Vector2(12, 42)
	])

	flame.color = Color("#ff9f1c")

	player.add_child(flame)


	# Camera
	var camera := Camera2D.new()

	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0

	player.add_child(camera)


# =========================================================
# OPPONENTS
# =========================================================

func create_opponents() -> void:

	create_opponent(
		Vector2(380, 560),
		Color("#4aa3ff"),
		430.0
	)

	create_opponent(
		Vector2(575, 620),
		Color("#ffd84a"),
		500.0
	)

	create_opponent(
		Vector2(770, 560),
		Color("#b56cff"),
		460.0
	)


func create_opponent(
	pos: Vector2,
	car_color: Color,
	speed: float
) -> void:

	var car := CharacterBody2D.new()

	car.name = "Opponent"

	car.position = pos

	car.set_meta(
		"speed",
		speed
	)

	car.set_meta(
		"lane_center",
		pos.x
	)

	car.set_meta(
		"lane_direction",
		1.0
	)

	add_child(car)

	opponents.append(car)


	# Collision
	var collision := CollisionShape2D.new()

	var shape := RectangleShape2D.new()

	shape.size = Vector2(
		55,
		95
	)

	collision.shape = shape

	car.add_child(collision)


	# Car image
	var sprite := Sprite2D.new()

	sprite.name = "CarSprite"

	sprite.texture = CAR_TEXTURE

	sprite.rotation_degrees = 180

	sprite.scale = Vector2(
		0.12,
		0.12
	)

	sprite.modulate = car_color

	car.add_child(sprite)


# =========================================================
# OPPONENT MOVEMENT
# =========================================================

func move_opponents() -> void:

	for car in opponents:

		if not is_instance_valid(car):
			continue

		var speed: float = car.get_meta("speed")

		var lane_center: float = car.get_meta("lane_center")

		var direction: float = car.get_meta("lane_direction")

		car.velocity.y = -speed

		car.position.x += (
			direction
			* 35.0
			* get_process_delta_time()
		)

		if car.position.x > lane_center + 100:
			car.set_meta(
				"lane_direction",
				-1.0
			)

		if car.position.x < lane_center - 100:
			car.set_meta(
				"lane_direction",
				1.0
			)

		car.position.x = clamp(
			car.position.x,
			TRACK_LEFT + 55,
			TRACK_RIGHT - 55
		)

		car.move_and_slide()


# =========================================================
# BOOST PADS
# =========================================================

func create_boost_pads() -> void:

	var positions := [
		Vector2(350, -800),
		Vector2(800, -2200),
		Vector2(450, -4000),
		Vector2(750, -6200),
		Vector2(400, -8500),
		Vector2(800, -10300)
	]

	for pos in positions:

		var pad := Area2D.new()

		pad.name = "BoostPad"

		pad.position = pos

		add_child(pad)


		var visual := Polygon2D.new()

		visual.polygon = PackedVector2Array([
			Vector2(-100, -25),
			Vector2(100, -25),
			Vector2(100, 25),
			Vector2(-100, 25)
		])

		visual.color = Color("#f1c40f")

		pad.add_child(visual)


		var collision := CollisionShape2D.new()

		var shape := RectangleShape2D.new()

		shape.size = Vector2(
			200,
			50
		)

		collision.shape = shape

		pad.add_child(collision)

		pad.body_entered.connect(
			_on_boost_pad_entered
		)


func _on_boost_pad_entered(body: Node2D) -> void:

	if body == player:

		player.boost_left = min(
			player.boost_left + 0.8,
			1.5
		)


# =========================================================
# OBSTACLES
# =========================================================

func create_obstacles() -> void:

	var positions := [
		Vector2(700, -1200),
		Vector2(300, -2600),
		Vector2(650, -3500),
		Vector2(400, -5000),
		Vector2(800, -7200),
		Vector2(350, -9000),
		Vector2(700, -10400)
	]

	for pos in positions:

		var obstacle := StaticBody2D.new()

		obstacle.name = "Obstacle"

		obstacle.position = pos

		add_child(obstacle)


		var visual := Polygon2D.new()

		visual.polygon = PackedVector2Array([
			Vector2(-35, -25),
			Vector2(35, -25),
			Vector2(35, 25),
			Vector2(-35, 25)
		])

		visual.color = Color("#e67e22")

		obstacle.add_child(visual)


		var collision := CollisionShape2D.new()

		var shape := RectangleShape2D.new()

		shape.size = Vector2(
			70,
			50
		)

		collision.shape = shape

		obstacle.add_child(collision)


# =========================================================
# HUD
# =========================================================

func create_hud() -> void:

	var hud := CanvasLayer.new()

	hud.name = "HUD"

	add_child(hud)


	position_label = Label.new()

	position_label.position = Vector2(
		30,
		30
	)

	position_label.add_theme_font_size_override(
		"font_size",
		28
	)

	hud.add_child(position_label)


	speed_label = Label.new()

	speed_label.position = Vector2(
		30,
		70
	)

	speed_label.add_theme_font_size_override(
		"font_size",
		24
	)

	hud.add_child(speed_label)


	boost_label = Label.new()

	boost_label.position = Vector2(
		30,
		105
	)

	boost_label.add_theme_font_size_override(
		"font_size",
		24
	)

	hud.add_child(boost_label)


func update_hud() -> void:

	if not is_instance_valid(player):
		return

	var player_y := player.position.y

	var place := 1

	for car in opponents:

		if is_instance_valid(car):

			if car.position.y < player_y:
				place += 1

	position_label.text = "POSITION: %s / 4" % place

	var speed := int(
		abs(player.velocity.y)
	)

	speed_label.text = "SPEED: %s" % speed

	var boost_time: float = player.boost_left

	var blocks := int(
		(boost_time / 1.5) * 10
	)

	blocks = clamp(
		blocks,
		0,
		10
	)

	boost_label.text = (
		"BOOST: "
		+ "█".repeat(blocks)
		+ "░".repeat(10 - blocks)
	)


# =========================================================
# COUNTDOWN
# =========================================================

func start_countdown() -> void:

	countdown_label = Label.new()

	countdown_label.position = Vector2(
		500,
		250
	)

	countdown_label.add_theme_font_size_override(
		"font_size",
		80
	)

	countdown_label.text = "3"

	$HUD.add_child(
		countdown_label
	)


	await get_tree().create_timer(
		1.0
	).timeout

	countdown_label.text = "2"


	await get_tree().create_timer(
		1.0
	).timeout

	countdown_label.text = "1"


	await get_tree().create_timer(
		1.0
	).timeout

	countdown_label.text = "GO!"

	race_started = true


	await get_tree().create_timer(
		0.8
	).timeout

	countdown_label.queue_free()


# =========================================================
# FINISH RESULT
# =========================================================

func check_finish() -> void:

	if player.position.y <= FINISH_Y:

		finish_race()


func finish_race() -> void:

	if race_finished:
		return

	race_finished = true

	race_started = false

	player.velocity = Vector2.ZERO

	var place := 1

	for car in opponents:

		if is_instance_valid(car):

			if car.position.y < player.position.y:
				place += 1

	show_results(place)


func show_results(place: int) -> void:

	var panel := ColorRect.new()

	panel.position = Vector2(
		300,
		140
	)

	panel.size = Vector2(
		550,
		360
	)

	panel.color = Color("#151515")

	$HUD.add_child(panel)


	var title := Label.new()

	title.position = Vector2(
		120,
		40
	)

	title.text = "RACE FINISHED!"

	title.add_theme_font_size_override(
		"font_size",
		38
	)

	panel.add_child(title)


	var result := Label.new()

	result.position = Vector2(
		190,
		120
	)

	result.text = "%s PLACE" % place

	result.add_theme_font_size_override(
		"font_size",
		50
	)

	panel.add_child(result)


	var again := Label.new()

	again.position = Vector2(
		125,
		280
	)

	again.text = "Press R to race again"

	again.add_theme_font_size_override(
		"font_size",
		24
	)

	panel.add_child(again)
