extends CharacterBody2D

@export var speed: float = 250
@export var friction: float = 200
@export var max_speed: float = 80
@export var jump_power: float = 80

var _gravity_areas: Array[GravityArea] = []
var _coyote_mode: bool = false

@onready var coyote_timer: Timer = $CoyoteTimer


func entered_gravity_area(area: GravityArea) -> void:
	_gravity_areas.append(area)


func _ready() -> void:
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(func():
		_coyote_mode = false)

func _physics_process(delta: float) -> void:
	var directional_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	for i in range(_gravity_areas.size()):
		if not _gravity_areas[i].overlaps_body(self):
			_gravity_areas.remove_at(i)
			i -= 1
			if _gravity_areas.is_empty():
				break
	
	if not _gravity_areas.is_empty():
		
		var priority_area = _gravity_areas[0]
		for a in _gravity_areas:
			if a.priority > priority_area.priority:
				priority_area = a
		

		var horizontal_movement = self.velocity.project(self.transform.x)
		# If the player is trying to keep going in the same direction
		var same_direction: bool = self.velocity.dot(
			self.transform.x * directional_input.x) > 0

		
		var rotation_goal: float = wrap(
			priority_area.get_gravity_point(self.global_position)
				.angle_to_point(self.global_position),
			0, TAU)
		
		self.rotation = lerp_angle(self.rotation, rotation_goal + PI/2, 0.8)


		if self.is_on_floor():
			_coyote_mode = true
		else:
			if _coyote_mode == true and coyote_timer.is_stopped():
				coyote_timer.start()
		
		# GRAVITY
		if not self.is_on_floor():
			self.velocity += priority_area.gravity * \
				-Vector2.from_angle(rotation_goal) * delta
		
		# WALK
		if horizontal_movement.length() <= max_speed or not same_direction:
			self.velocity += self.transform.x * directional_input.x * speed * delta
		
		# FRICTION
		if not same_direction:
			# unless the player is trying to go in the same direction
			var friction_force = -horizontal_movement.normalized() * \
				friction * delta
			self.velocity += friction_force
			
			if horizontal_movement.length() <= friction_force.length()/2:
				# I think this doesn't work sometimes but it seems to fix itself
				# after a moment, so idk
				self.velocity -= horizontal_movement
		
		# if horizontal_movement.length() > max_speed:
		# 	self.velocity -= horizontal_movement - horizontal_movement.limit_length(max_speed)
		if _coyote_mode and Input.is_action_just_pressed("jump"):
			self.velocity += -self.transform.y * jump_power
	
	self.move_and_slide()
	
	self.up_direction = -self.transform.y
