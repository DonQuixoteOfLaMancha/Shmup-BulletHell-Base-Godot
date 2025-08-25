extends GameEntity

class_name PlayerEntity

#Variables
var fire_cooldown : float = 0.0

var swap_timer : float = 0.0
var swap_start_x : float = 0.0
var swap_start_y : float = 0.0
var swap_target_x : float = 0.0
var swap_target_y : float = 0.0
var swapping_in : bool = false

#Override Variables
var bullet_type : EntitySpawnWave = null
var fire_delay : float = 0.0

var move_speed : float = 0.0 #How fast the character moves when inputted upon
var vertical_movement : bool = true #Whether the character can move vertically or not (use true for bullet hells, use false for basic shmups)

var swap_out_time : float = 0.0 #<= 0 will result in an instant swap out
var swap_in_time : float = 0.0 #<= 0 will result in an instant swap in


#Sets override variables
func _init(initial_position_x: float = 0.0, initial_position_y: float = 0.0, source_entity: GameEntity = null,
			switching_places: bool = false, switch_target_pos_x: float = 0.0, switch_target_pos_y: float = 0.0) -> void:
	super(initial_position_x, initial_position_y, source_entity)
	
	
	swapping_in = switching_places
	if(swapping_in):
		swap_timer = swap_in_time
		swap_start_x = initial_position_x
		swap_start_y = initial_position_y
		swap_target_x = switch_target_pos_x
		swap_target_y = switch_target_pos_y
		if(swap_timer <= 0):
			swapping_in = false
			position.x = swap_target_x
			position.y = swap_target_y
	
	oob_time_limit = -1
	initial_health = 100

func _ready() -> void:
	super()
	
	Global.player = self


func _process(delta: float) -> void:
	super(delta)
	
	velocity_x = 0
	velocity_y = 0
	
	#Fire rate limit
	if(fire_cooldown > 0):
		fire_cooldown -= delta
	
	#Swapping in and out
	if(swap_timer > 0):
		position.x += delta*(swap_target_x-swap_start_x)
		position.y += delta*(swap_target_y-swap_start_y)
		swap_timer -= delta
		if(swap_timer <= 0.5*delta):
			swap_timer = 0
			position.x = swap_target_x
			position.y = swap_target_y
			if(swapping_in):
				swapping_in = false
			else:
				add_sibling(Global.player_chars[Global.player_char_index].new(position.x, position.y, null, true, swap_start_x, swap_start_y))
				queue_free()

func _unhandled_input(event): #Handling movement, fire, and switch controls
	if(swap_timer <= 0):
		if event is InputEventKey: 
			if event.pressed and event.keycode == KEY_LEFT:
				velocity_x = -move_speed
			if event.pressed and event.keycode == KEY_RIGHT:
				velocity_x = move_speed
			if event.pressed and event.keycode == KEY_UP && vertical_movement:
				velocity_y = -move_speed
			if event.pressed and event.keycode == KEY_DOWN && vertical_movement:
				velocity_y = move_speed
			if event.pressed and event.keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6,KEY_7,KEY_8,KEY_9]:
				if(int(OS.get_keycode_string(event.keycode)) <= Global.player_chars.size() and int(OS.get_keycode_string(event.keycode)) != Global.player_char_index): #Code for swapping out to another type
					swapping_in = false
					swap_timer = swap_out_time
					swap_start_x = position.x
					swap_start_y = position.y
					swap_target_x = position.x
					swap_target_y = Global.screen_bounds[1]+collision_size_y
					Global.player_char_index = int(OS.get_keycode_string(event.keycode))
					if(swap_timer <= 0):
						add_sibling(Global.player_chars[Global.player_char_index].new(position.x, position.y, null, true, swap_start_x, swap_start_y))
						queue_free()
		elif event is InputEventMouseButton:
			if event.pressed and event.button_index == 1:
				_fire()


func _fire():
	if(fire_cooldown <= 0):
		for spawn_index in range (0,bullet_type.entity_spawn_list.size()): #spawns the bullet(s)
			var spawn_entity_pos_x = bullet_type.entity_spawn_list[spawn_index].spawn_position[0]
			var spawn_entity_pos_y = bullet_type.entity_spawn_list[spawn_index].spawn_position[1]
			var spawn_entity : GameEntity = bullet_type.entity_spawn_list[spawn_index].spawn_entity.new(spawn_entity_pos_x+position.x, spawn_entity_pos_y+position.y , self)
			add_sibling(spawn_entity)
		fire_cooldown = fire_delay
