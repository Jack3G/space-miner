extends Control

@export var gold_prefix: String = "Gold Collected: "
@export var duration_prefix: String = "Time Spent Alive: "

var _characters_in_gold_count: int = 0
var _characters_in_duration: int = 0

# we need these because load_ui_package is called before the node is ready
var _gold_text: String = ""
var _duration_text: String = ""
var _new_high_score: bool = false

@onready var gold: Label = %Gold
@onready var duration: Label = %Duration
@onready var menu_button: Button = %MenuButton
@onready var text_scroll: AudioStreamPlayer = $TextScroll
@onready var highscore: Control = %Highscore
@onready var highscore_sound: AudioStreamPlayer = $HighscoreSound


func load_ui_package(package: Dictionary) -> void:
	if package.has("gold"):
		_gold_text = gold_prefix + str(package.gold)
		_characters_in_gold_count = str(package.gold).length()

	if package.has("game_time"):
		var seconds = package.game_time as float / 1000.0
		var minutes = floorf(seconds / 60)
		var hours = floorf(minutes / 60)

		seconds -= minutes * 60
		seconds -= hours * 60 * 60

		var str_hours = ""
		if hours > 0:
			str_hours = str(hours) + ":"
		var time = str_hours + str(minutes) + ":" + str(seconds)

		_duration_text = duration_prefix + str(time)
		_characters_in_duration = str(time).length()

	var save_file = ConfigFile.new()
	var err = save_file.load("user://save.ini")
	if err != OK:
		print("Couldn't load the save file. Creating a new one.")
		save_file.set_value("highscore", "gold", -1)
		save_file.set_value("highscore", "duration", -1)

	if save_file.has_section_key("highscore", "gold") and package.has("gold"):
		if package.gold >= save_file.get_value("highscore", "gold"):
			save_file.set_value("highscore", "gold", package.gold)
			_new_high_score = true
	if save_file.has_section_key("highscore", "duration") and package.has("game_time"):
		if package.game_time >= save_file.get_value("highscore", "duration"):
			save_file.set_value("highscore", "duration", package.game_time)
			_new_high_score = true

	save_file.save("user://save.ini")

func _ready() -> void:
	menu_button.pressed.connect(func():
		get_tree().get_root().add_child(load("res://src/main_menu.tscn").instantiate())
		self.queue_free())

	menu_button.grab_focus.call_deferred()
	
	gold.text = _gold_text
	duration.text = _duration_text

	gold.visible_characters = 0
	duration.visible_characters = 0

	await get_tree().create_timer(3).timeout

	text_scroll.play()
	await self.create_tween().tween_property(
		gold, "visible_characters",
		gold.text.length() - _characters_in_gold_count, 1).finished
	await get_tree().create_timer(1).timeout
	
	await self.create_tween().tween_property(
		gold, "visible_characters",
		gold.text.length(), 1).finished
	await get_tree().create_timer(1).timeout

	text_scroll.play()
	await self.create_tween().tween_property(
		duration, "visible_characters",
		duration.text.length() - _characters_in_duration, 1).finished
	await get_tree().create_timer(1).timeout
	
	await self.create_tween().tween_property(
		duration, "visible_characters",
		duration.text.length(), 1).finished
	await get_tree().create_timer(1).timeout

	if _new_high_score:
		for i in range(3):
			highscore.visible_characters = -1
			highscore_sound.play()
			await get_tree().create_timer(0.5).timeout
			highscore.visible_characters = 1
			await get_tree().create_timer(0.5).timeout
		highscore.visible_characters = -1
