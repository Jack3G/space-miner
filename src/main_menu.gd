extends Control

@export var background_scroll: Vector2 = Vector2(30, 20)
@export var spaceman_velocity: Vector2 = Vector2(20, 30)

@onready var background: ParallaxBackground = $ParallaxBackground
@onready var title: Label = %Title
@onready var play_button: Button = %PlayButton
@onready var spaceman: CharacterBody2D = %FloatingSpaceMan
@onready var play_pressed: AudioStreamPlayer = $PlayPressed


func _ready() -> void:
	play_button.grab_focus.call_deferred()

	play_button.pressed.connect(func():
		play_pressed.play()
		await self.create_tween().tween_property(
			self, "modulate", Color.BLACK, play_pressed.stream.get_length()).finished

		get_tree().get_root().add_child(load("res://src/game.tscn").instantiate())
		self.queue_free())

	spaceman.velocity = spaceman_velocity

	title.visible_ratio = 0
	await self.create_tween().tween_property(title, "visible_ratio", 1, 3).finished

func _process(delta: float) -> void:
	background.scroll_offset += background_scroll * delta
	spaceman.rotation -= PI/2 * delta

func _physics_process(delta: float) -> void:
	if spaceman.move_and_slide():
		var collision = spaceman.get_last_slide_collision()
		spaceman.velocity = spaceman.velocity.bounce(collision.get_normal())
