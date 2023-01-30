@tool
extends Node2D


func _draw() -> void:
	if Engine.is_editor_hint():
		var radius: float = self.position.distance_to(Vector2.ZERO)
		var pos: Vector2 = -self.position
		draw_arc(pos, radius, 0, TAU, 16, Color.LIGHT_BLUE)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		self.queue_redraw()
