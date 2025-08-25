extends GameEntity

class_name Enemy

func _init(initial_position_x: float = 0.0, initial_position_y: float = 0.0, source_entity: GameEntity = null) -> void:
	super(initial_position_x, initial_position_y, source_entity)
	
	collision_team = 1
