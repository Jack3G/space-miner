extends Area2D
class_name GravityArea


func get_gravity_point(object: Vector2) -> Vector2:
	## This function takes an object's position, and returns a position which
	## the object should be attracted to. All coordinates are global.

	# or at least it will when I need more than just a circle
	return self.global_position


func _ready() -> void:
	self.body_entered.connect(func(body: Node2D):
		if body.is_in_group("characters"):
			body.entered_gravity_area(self))
