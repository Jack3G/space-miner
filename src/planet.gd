extends StaticBody2D

@export var points: int = 32
@export var size_curve: Curve
@export var surface_offset: Noise
@export var offset_scale: float = 10
@export var atmosphere_height: float = 60
@export var atmosphere_points: int = 64
@export var atmosphere_color: Color
@export var gravity: float = 200

@export var textures: Array[Texture]

@onready var max_size: Node2D = $MaxSize
@onready var min_size: Marker2D = $MinSize

func _ready() -> void:
	var collision = CollisionPolygon2D.new()
	var visual_polygon = Polygon2D.new()
	var polygon = PackedVector2Array()

	var max_len = max_size.position.length()
	var min_len = min_size.position.length()

	var radius = size_curve.sample(randf()) * (max_len - min_len) + min_len
	
	for i in range(points):
		var angle_ratio: float = i as float / points as float
		var angle: float = angle_ratio * TAU

		var offset: float = surface_offset.get_noise_1d(angle_ratio * PI * radius**2)

		var new_point = Vector2.from_angle(angle) * (radius + offset * offset_scale)
		polygon.append(new_point)

	collision.polygon = polygon
	self.add_child(collision)

	visual_polygon.polygon = polygon
	visual_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	visual_polygon.texture = textures.pick_random()
	self.add_child(visual_polygon)
	
	
	var gravity_area = GravityArea.new()
	gravity_area.gravity_space_override = Area2D.SPACE_OVERRIDE_COMBINE
	gravity_area.gravity_point = true
	gravity_area.gravity_point_center = Vector2.ZERO
	gravity_area.gravity = gravity

	var gravity_collision = CollisionShape2D.new()
	gravity_collision.shape = CircleShape2D.new()
	gravity_collision.shape.radius = radius + atmosphere_height
	
	gravity_area.add_child(gravity_collision)
	self.add_child(gravity_area)


	var atmosphere: Polygon2D = Polygon2D.new()
	var atmo_poly: Array[Vector2] = []
	for i in range(atmosphere_points):
		var direction = Vector2.from_angle((i as float / atmosphere_points as float) * TAU)
		atmo_poly.append(direction * (radius + atmosphere_height))
	atmosphere.polygon = PackedVector2Array(atmo_poly)
	atmosphere.color = atmosphere_color
	atmosphere.z_index = -5
	self.add_child(atmosphere)
