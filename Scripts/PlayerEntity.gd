extends GameEntity

class_name PlayerEntity

#Variables
var fire_cooldown : float = 0.0

#Override Variables
var bullet_type : EntitySpawnWave = null
var fire_delay : float = 0.0

var move_speed : float = 0.0
var vertical_movement : bool = true


#Sets override variables
func _init(initial_position_x: float = 0.0, initial_position_y: float = 0.0, source_entity: GameEntity = null) -> void:
	super(initial_position_x, initial_position_y, source_entity)
	
	oob_time_limit = -1
	initial_health = 100


func _process(delta: float) -> void:
	super(delta)
	
	velocity_x = 0
	velocity_y = 0
	
	if(fire_cooldown > 0):
		fire_cooldown -= delta


func _unhandled_input(event): #Handling movement controls
	if event is InputEventKey: 
		if event.pressed and event.keycode == KEY_LEFT:
			velocity_x = -move_speed
		if event.pressed and event.keycode == KEY_RIGHT:
			velocity_x = move_speed
		if event.pressed and event.keycode == KEY_UP && vertical_movement:
			velocity_y = -move_speed
		if event.pressed and event.keycode == KEY_DOWN && vertical_movement:
			velocity_y = move_speed
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			_fire()


func _fire():
	if(fire_cooldown <= 0):
		for spawn_index in range (0,bullet_type.size()): #spawns the bullet(s)
			var spawn_entity_pos_x = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_position[0]
			var spawn_entity_pos_y = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_position[1]
			var spawn_entity : GameEntity = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_entity.new(spawn_entity_pos_x+position.x, spawn_entity_pos_y+position.y , self)
			get_parent().add_child(spawn_entity)
		fire_cooldown = fire_delay
