extends Control

@export var radar_scale: float = 0.025
@export var radar_blip_size: Vector2 = Vector2(2, 2)
@export var radar_radius_offset: float = -5

var _blips: Array[Vector2] = []

@onready var health_bar: ProgressBar = %Health
@onready var boost_meter: ProgressBar = %BoostMeter
@onready var radar: TextureRect = %Radar
@onready var gold: Label = %Gold
@onready var exit_prompt: Control = %ExitPrompt

func load_ui_package(package: Dictionary) -> void:
	if package.has("boost_charge_max"):
		boost_meter.max_value = package.boost_charge_max
	if package.has("boost_charge"):
		boost_meter.value = package.boost_charge

	if package.has("oxygen_max"):
		health_bar.max_value = package.oxygen_max
	if package.has("oxygen"):
		health_bar.value = package.oxygen

	if package.has("blips"):
		_blips = package.blips
	if package.has("gold"):
		gold.text = str(package.gold)

	self.queue_redraw()

func _draw() -> void:
	var radar_mid: Vector2 = radar.position + radar.size / 2
	var radar_radius: float = min(radar.size.x, radar.size.y)/2

	for b in _blips:
		var rect = Rect2(
			radar_mid + (b * radar_scale).limit_length(radar_radius + radar_radius_offset
				) - radar_blip_size / 2,
			radar_blip_size)
		self.draw_rect(rect, Color.GREEN)
