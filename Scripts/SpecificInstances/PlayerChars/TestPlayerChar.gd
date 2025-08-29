extends PlayerEntity

class_name TestPlayerChar

func _init(initial_position_x: float = 0.0, initial_position_y: float = 0.0, source_entity: GameEntity = null,
			switching_places: bool = false, switch_target_pos_x: float = 0.0, switch_target_pos_y: float = 0.0) -> void:
	super(initial_position_x, initial_position_y, source_entity,
			switching_places, switch_target_pos_x, switch_target_pos_y)
	
	move_speed = 200
	fire_delay = 5
	bomb_delay = 2
	spritesheet = null
	sprite = preload("res://icon.svg")
	bullet_type = TestPlayerBulletSpawn.new()
	bomb_types = [TestBombSpawn.new()]
