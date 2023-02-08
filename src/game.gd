extends Node2D

var _character: CharacterBody2D = null
var _hud: Control = null

@onready var ui_layer: CanvasLayer = $UILayer

func _ready() -> void:
	var new_character = preload("res://src/character.tscn").instantiate()
	_character = new_character
	self.add_child(new_character)

	var new_hud = preload("res://src/hud.tscn").instantiate()
	_hud = new_hud
	ui_layer.add_child(new_hud)


func _process(delta: float) -> void:
	_hud.load_ui_package(_character.get_ui_package())
