extends Control

@export var background_scroll: Vector2 = Vector2(30, 20)

@onready var background: ParallaxBackground = $ParallaxBackground
@onready var title: Label = %Title
@onready var play_button: Button = %PlayButton
@onready var spaceman: Sprite2D = %FloatingSpaceMan
@onready var animation: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	play_button.grab_focus.call_deferred()

	play_button.pressed.connect(func():
		get_tree().get_root().add_child(load("res://src/game.tscn").instantiate())
		self.queue_free())

	title.visible_ratio = 0
	await self.create_tween().tween_property(title, "visible_ratio", 1, 3).finished

	animation.current_animation = "he orbit"

func _process(delta: float) -> void:
	background.scroll_offset += background_scroll * delta
	spaceman.rotation -= PI/2 * delta
