extends Area2D

@export var textures: Array[Texture2D] = []
## A dictionary where the keys are Resources.Ore and the value is the amount
@export var drops: Dictionary = {}

var _broken: bool = false

@onready var break_particles: GPUParticles2D = $BreakParticles
@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	sprite.texture = textures.pick_random()

	var anim = self.get_node_or_null("AnimationPlayer")
	if anim:
		anim.current_animation = "sparkle"

func break_rock() -> Dictionary:
	if _broken:
		return {}

	_broken = true
	
	break_particles.emitting = true
	sprite.visible = false
	collision.set_deferred("disabled", true)
	return drops
