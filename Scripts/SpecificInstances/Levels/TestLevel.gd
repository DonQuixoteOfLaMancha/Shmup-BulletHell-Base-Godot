extends Level

class_name TestLevel

func _init() -> void:
	name = "Test"
	spawn_waves = [TestWave.new(), TestWave.new()]
	spawn_wave_delays = [10,10]
	background_img = preload("res://icon.svg")
