extends Control


@onready var health_bar: ProgressBar = %Health
@onready var boost_meter: ProgressBar = %BoostMeter


func load_ui_package(package: Dictionary) -> void:
	if package.boost_charge_max:
		boost_meter.max_value = package.boost_charge_max

	if package.boost_charge:
		boost_meter.value = package.boost_charge
