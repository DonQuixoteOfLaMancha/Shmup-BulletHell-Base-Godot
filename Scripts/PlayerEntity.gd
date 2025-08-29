extends GameEntity

class_name PlayerEntity

#Variables
var fire_cooldown : float = 0.0
var bomb_cooldown : float = 0.0

var swap_timer : float = 0.0
var swap_start_x : float = 0.0
var swap_start_y : float = 0.0
var swap_target_x : float = 0.0
var swap_target_y : float = 0.0
var swapping_in : bool = false

#Override Variables
var bullet_type : EntitySpawnWave = null
var fire_delay : float = 0.0

var bomb_types : Array[EntitySpawnWave] = []
var bomb_delay : float = 0.0

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
	health = Global.player_health

func _ready() -> void:
	super()
	
	Global.player = self


func _process(delta: float) -> void:
	super(delta)
	
	#Reset velocity for when keys not pressed
	velocity_x = 0
	velocity_y = 0
	
	#Input handling
	if(swap_timer <= 0):
		if Input.is_action_pressed("move_right"):
			velocity_x += move_speed
		if Input.is_action_pressed("move_left"):
			velocity_x -= move_speed
		if Input.is_action_pressed("move_down") and vertical_movement:
			velocity_y += move_speed
		if Input.is_action_pressed("move_up") and vertical_movement:
			velocity_y -= move_speed
		if Input.is_action_pressed("fire"):
			_fire()
	
	
	#Keeps the player in bounds
	if(position.x-collision_size_x < 0):
		position.x = collision_size_x
	elif(position.x+collision_size_x > Global.screen_bounds[0]):
		position.x = Global.screen_bounds[0]-collision_size_x
	if(position.y-collision_size_y < 0):
		position.y = collision_size_y
	elif(position.y+collision_size_y > Global.screen_bounds[1]):
		position.y = Global.screen_bounds[1]-collision_size_y
	
	
	#Fire rate and bomb rate limit
	if(fire_cooldown > 0):
		fire_cooldown -= delta
	if(bomb_cooldown > 0):
		bomb_cooldown -= delta
	
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
				get_parent().move_child(get_parent().get_child(get_parent().get_child_count()-1), 0)
				queue_free()

func _unhandled_input(event): #Handling movement, fire, and switch controls
	if(swap_timer <= 0):
		if event is InputEventKey: 
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
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_C:
			_bomb(0)


func _fire():
	if(fire_cooldown <= 0):
		if(bullet_type != null):
			for spawn_index in range (0,bullet_type.entity_spawn_list.size()): #spawns the bullet(s)
				var spawn_entity_pos_x = bullet_type.entity_spawn_list[spawn_index].spawn_position[0]
				var spawn_entity_pos_y = bullet_type.entity_spawn_list[spawn_index].spawn_position[1]
				var spawn_entity : GameEntity = null
				if(bullet_type.entity_spawn_list[spawn_index].spawn_entity.new().is_a_bullet):
					var spawn_entity_vel_x = bullet_type.entity_spawn_list[spawn_index].spawn_velocity[0]
					var spawn_entity_vel_y = bullet_type.entity_spawn_list[spawn_index].spawn_velocity[1]
					var spawn_entity_acc_x = bullet_type.entity_spawn_list[spawn_index].acceleration[0]
					var spawn_entity_acc_y = bullet_type.entity_spawn_list[spawn_index].acceleration[1]
					var spawn_entity_team = bullet_type.entity_spawn_list[spawn_index].spawn_team
					spawn_entity = bullet_type.entity_spawn_list[spawn_index].spawn_entity.new(spawn_entity_pos_x+position.x, spawn_entity_pos_y+position.y, self, spawn_entity_vel_x, spawn_entity_vel_y, spawn_entity_acc_x, spawn_entity_acc_y, spawn_entity_team)
				else:
					spawn_entity = bullet_type.entity_spawn_list[spawn_index].spawn_entity.new(spawn_entity_pos_x+position.x, spawn_entity_pos_y+position.y, self)
				add_sibling(spawn_entity)
		fire_cooldown = fire_delay

func _bomb(index : int = 0):
	if(index < bomb_types.size() && bomb_cooldown <= 0 && Global.bombs_used < Global.max_bombs):
		if(bomb_types[index] != null):
			for spawn_index in range (0,bomb_types[index].entity_spawn_list.size()): #spawns the bullet(s)
				var spawn_entity_pos_x = bomb_types[index].entity_spawn_list[spawn_index].spawn_position[0]
				var spawn_entity_pos_y = bomb_types[index].entity_spawn_list[spawn_index].spawn_position[1]
				var spawn_entity : GameEntity = null
				if(bomb_types[index].entity_spawn_list[spawn_index].spawn_entity.new().is_a_bullet):
					var spawn_entity_vel_x = bomb_types[index].entity_spawn_list[spawn_index].spawn_velocity[0]
					var spawn_entity_vel_y = bomb_types[index].entity_spawn_list[spawn_index].spawn_velocity[1]
					var spawn_entity_acc_x = bomb_types[index].entity_spawn_list[spawn_index].acceleration[0]
					var spawn_entity_acc_y = bomb_types[index].entity_spawn_list[spawn_index].acceleration[1]
					var spawn_entity_team = bomb_types[index].entity_spawn_list[spawn_index].team
					spawn_entity = bomb_types[index].entity_spawn_list[spawn_index].spawn_entity.new(spawn_entity_pos_x+position.x, spawn_entity_pos_y+position.y, self, spawn_entity_vel_x, spawn_entity_vel_y, spawn_entity_acc_x, spawn_entity_acc_y, spawn_entity_team)
				else:
					spawn_entity = bomb_types[index].entity_spawn_list[spawn_index].spawn_entity.new(spawn_entity_pos_x+position.x, spawn_entity_pos_y+position.y, self)
				add_sibling(spawn_entity)
			Global.bombs_used += 1
		bomb_cooldown = bomb_delay

func _damage(damage_amount: float):
	super(damage_amount)
	Global.player_health = health
