extends CharacterBody2D

@export var speed: float = 250
@export var friction: float = 200
@export var max_speed: float = 80

var gravity_areas: Array[GravityArea] = []

func entered_gravity_area(area: GravityArea) -> void:
	gravity_areas.append(area)

func _physics_process(delta: float) -> void:
	var directional_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	for i in range(gravity_areas.size()):
		if not gravity_areas[i].overlaps_body(self):
			gravity_areas.remove_at(i)
			i -= 1
			if gravity_areas.is_empty():
				break
	
	if not gravity_areas.is_empty():
		
		var priority_area = gravity_areas[0]
		for a in gravity_areas:
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
		
#		if horizontal_movement.length() > max_speed:
#			self.velocity -= horizontal_movement - horizontal_movement.limit_length(max_speed)
	
	self.move_and_slide()
	
	self.up_direction = -self.transform.y
