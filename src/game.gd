extends Node2D

@export var planet_distance_min: float = 320
@export var planet_spawn_attempts: int = 50

var _character: CharacterBody2D = null
var _hud: Control = null
var _camera: Camera2D = null

@onready var ui_layer: CanvasLayer = $UILayer
@onready var background: Sprite2D = $Background
@onready var player_start_pos: Node2D = $PlayerStartPos
@onready var planet_spawn_area: Area2D = $PlanetSpawnArea

# this is broken and I don't know how to make it work :(
func get_camera_top_left(camera: Camera2D) -> Vector2:
	var middle: Vector2 = camera.global_position
	var viewport_size: Vector2 = get_viewport_rect().size

	var points: Array[Vector2] = []
	for v in [Vector2(-0.5, -0.5), Vector2(-0.5, 0.5), Vector2(0.5, -0.5), Vector2(0.5, 0.5)]:
		var unrotated = middle + viewport_size * v
		var rotated = unrotated.rotated(camera.global_rotation)
		points.append(rotated)

	var smallest: Vector2 = Vector2.INF
	for p in points:
		if p.x < smallest.x:
			smallest.x = p.x
		if p.y < smallest.y:
			smallest.y = p.y

	assert(smallest.is_finite())

	return smallest

func _ready() -> void:
	# Instantiate game objects
	var new_character = preload("res://src/character.tscn").instantiate()
	new_character.position = player_start_pos.position
	_character = new_character
	self.add_child(new_character)

	var new_camera = Camera2D.new()
	new_camera.ignore_rotation = false
	new_camera.rotation_smoothing_enabled = true
	new_camera.rotation_smoothing_speed = 10
	_camera = new_camera
	_character.add_child(new_camera)
	_camera.enabled = true

	var new_hud = preload("res://src/hud.tscn").instantiate()
	_hud = new_hud
	ui_layer.add_child(new_hud)


	# Setup background
	background.centered = false
	var bg_rect = background.get_rect()
	var visible_diagonal_length = (get_viewport_rect().size * (Vector2.ONE / _camera.zoom)).length()
	assert(visible_diagonal_length < bg_rect.size.x * 3, "The background isn't wide enough")
	assert(visible_diagonal_length < bg_rect.size.y * 3, "The background isn't tall enough")

	var bg_nodes_buffer: Array[Sprite2D] = []
	for unit_pos in [
			Vector2(1, 0), Vector2(2, 0),
			Vector2(0, 1), Vector2(1, 1), Vector2(2, 1),
			Vector2(0, 2), Vector2(1, 2), Vector2(2, 2),
		]:
		# Instantiate so that changes to the original change the copies too.
		var new_copy = background.duplicate(Node.DUPLICATE_USE_INSTANTIATION)
		new_copy.position += bg_rect.size * unit_pos
		bg_nodes_buffer.append(new_copy)

	for node in bg_nodes_buffer:
		background.add_child(node)


	# Generate planets
	var collision_shape: CollisionShape2D = planet_spawn_area.get_node("CollisionShape2D")
	assert(collision_shape.shape is RectangleShape2D)
	var half_size: Vector2 = collision_shape.shape.size / 2

	var planet_seeds: Array[Vector2] = []
	for i in range(planet_spawn_attempts):
		var new_seed = Vector2(
			randf_range(collision_shape.position.x - half_size.x,
				collision_shape.position.x + half_size.x),
			randf_range(collision_shape.position.y - half_size.y,
				collision_shape.position.y + half_size.y),
		)

		var has_space = true
		for planet in get_tree().get_nodes_in_group("planets"):
			var distance = planet.position.distance_to(new_seed)
			if distance < planet_distance_min:
				has_space = false
		for p_seed in planet_seeds:
			var distance = p_seed.distance_to(new_seed)
			if distance < planet_distance_min:
				has_space = false

		if has_space:
			planet_seeds.append(new_seed)

	for planet_seed in planet_seeds:
		var new_planet = preload("res://src/planet.tscn").instantiate()
		new_planet.position = planet_seed
		self.add_child(new_planet)


func _process(delta: float) -> void:
	_hud.load_ui_package(_character.get_ui_package())

	# temporary (permanent) hack because I cant get the top left of the camera
	background.position = (_camera.global_position - get_viewport_rect().size * 1.5
		).snapped(background.get_rect().size)
