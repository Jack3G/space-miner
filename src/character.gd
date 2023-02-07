extends CharacterBody2D

@export var speed: float = 250
@export var friction: float = 200
@export var max_speed: float = 80
@export var jump_power: float = 100
@export var boost_direction_default: Vector2 = Vector2.UP
@export var boost_jump_cooldown: float = 1.5
@export var terminal_velocity: float = 1000

var _gravity_areas: Array[GravityArea] = []
var _coyote_mode: bool = false
# to prevent jumping multiple times in coyote time
var _jumped: bool = true
var _can_boost_jump: bool = true
var _angular_velocity: float = 0

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var boost_particles: GPUParticles2D = $BoostPackParticles
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite


func entered_gravity_area(area: GravityArea) -> void:
	_gravity_areas.append(area)


func _ready() -> void:
	coyote_timer.one_shot = true
	coyote_timer.timeout.connect(func():
		_coyote_mode = false)

func _physics_process(delta: float) -> void:
	var directional_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var i = 0
	while i < _gravity_areas.size():
		if not _gravity_areas[i].overlaps_body(self):
			_gravity_areas.remove_at(i)
			i -= 1
			if _gravity_areas.is_empty():
				break
		i += 1

	var on_planet = not _gravity_areas.is_empty()

	# ANIMATIONS
	if on_planet and directional_input != Vector2.ZERO:
		animation.current_animation = "walk"
	else:
		animation.current_animation = "RESET"

	if directional_input != Vector2.ZERO:
		sprite.flip_h = directional_input.x < 0
		
	
	if on_planet:
		var priority_area = _gravity_areas[0]
		for a in _gravity_areas:
			if a.priority > priority_area.priority:
				priority_area = a
		

		var horizontal_movement = self.velocity.project(self.transform.x)
		# If the player is trying to keep going in the same direction
		var same_direction: bool = self.velocity.dot(
			self.transform.x * directional_input.x) > 0

		
		_angular_velocity = 0

		var rotation_goal: float = wrap(
			priority_area.get_gravity_point(self.global_position)
				.angle_to_point(self.global_position),
			0, TAU)
		
		self.rotation = lerp_angle(self.rotation, rotation_goal + PI/2, 0.3)


		if self.is_on_floor():
			_coyote_mode = true
			_jumped = false
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
		if not same_direction or horizontal_movement.length() > max_speed:
			# unless the player is trying to go in the same direction
			var friction_force = -horizontal_movement.normalized() * \
				friction * delta
			self.velocity += friction_force
			
			if horizontal_movement.length() <= friction_force.length()/2:
				# I think this doesn't work sometimes but it seems to fix itself
				# after a moment, so idk
				self.velocity -= horizontal_movement
	else: # If in space
		self.rotation += _angular_velocity * delta
		
	# JUMP
	if Input.is_action_just_pressed("jump"):
		if _coyote_mode and not _jumped and on_planet:
			_jumped = true
			var impulse = -self.transform.y * jump_power
			
			# If the character is moving down cancel that downwards velocity and then add jump.
			# I.e. walking down slopes doesn't eat jumps
			if -self.transform.y.dot(self.velocity) < 0:
				impulse += -self.velocity.project(self.transform.y)
				
			self.velocity += impulse
		elif _can_boost_jump:
			_can_boost_jump = false
			get_tree().create_timer(boost_jump_cooldown, false).timeout.connect(func():
				_can_boost_jump = true)

			var input_dir = directional_input
			if input_dir == Vector2.ZERO:
				input_dir = boost_direction_default
				
			var dir = -input_dir
				
			boost_particles.process_material.direction.x = dir.x
			boost_particles.process_material.direction.y = dir.y

			boost_particles.emitting = false
			boost_particles.restart()
			boost_particles.emitting = true

			self.velocity += input_dir.rotated(self.rotation) * jump_power

	self.velocity = self.velocity.limit_length(terminal_velocity)

	self.move_and_slide()
	
	self.up_direction = -self.transform.y
