extends Enemy

class_name TestEnemy

func _init(initial_position_x: float = 0.0, initial_position_y: float = 0.0, source_entity: GameEntity = null) -> void:
	super(initial_position_x, initial_position_y, source_entity)
	
	velocity_y = 20
	acceleration_x = 0.1
	collision_size_x = 50
	collision_size_y = 50
	score_value = 10
	damage = 5
