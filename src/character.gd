extends CharacterBody2D

@export var speed: float = 40

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
		
		var rotation_goal: float = wrap(
			priority_area.get_gravity_point(self.global_position)
				.angle_to_point(self.global_position),
			0, TAU)
		
		self.rotation = lerp_angle(self.rotation, rotation_goal + PI/2, 0.8)
		
		if not self.is_on_floor():
			self.velocity += priority_area.gravity * \
				-Vector2.from_angle(rotation_goal) * delta
		
		self.velocity += self.transform.x * directional_input.x * speed * delta
	
	self.move_and_slide()
	
	self.up_direction = -self.transform.y
