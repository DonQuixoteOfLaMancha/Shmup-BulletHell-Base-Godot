extends GameEntity

class_name Bullet

func _init(initial_position_x: float = 0.0, initial_position_y: float = 0.0, source_entity: GameEntity = null,
			start_vel_x : float = 0.0, start_vel_y : float = 0.0, accel_x : float = 0.0, accel_y : float = 0.0) -> void:
	super(initial_position_x, initial_position_y, source_entity)
	
	initial_velocity_x = start_vel_x
	velocity_x = initial_velocity_x
	initial_velocity_y - start_vel_y
	velocity_y = initial_velocity_y
	acceleration_x = accel_x
	acceleration_y = accel_y
	
	is_a_bullet = true
	collide_with_bullets = false
