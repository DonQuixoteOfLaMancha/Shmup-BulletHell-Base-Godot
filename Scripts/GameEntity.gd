@tool
extends Node2D

class_name GameEntity


#Variables
var velocity_x : float = 0.0 #Set these to what you want their inital values to be, accel is lower down
var velocity_y : float = 0.0

var health : float = 0.0 # Set to starting health of the entity (unless player, which is set via global) (<= will cause instant death on collision)

var firing_index : int = 0
var firing_cooldown : float = 0.0
var fire_loop_count : int = -1 #loop count below 0 will result in infinite looping

var oob_time_passed : float = 0.0 #tracks time spent out of bounds
var lifetime : float = 0.0 #How long the object lives, if <= 0

var collided_entities : Array[GameEntity] = [self]

#Dev variables
@export var show_trajectory : bool = false
@export var follow_trajectory : bool = false
var follow_traj_previous_state : bool = follow_trajectory
var dev_initial_pos : Vector2 = position
@export var dev_traj_timer : float = 0.0
@export var trajectory_steps : int = 0
@export var show_bounds : bool = false
@export var editor_sprite : Texture2D = sprite :
	set(value):
		editor_sprite = value
		if(editor_sprite_frames == null):
			get_child(0).texture = editor_sprite
	get:
		return editor_sprite
@export var editor_sprite_frames : SpriteFrames = spritesheet :
	set(value):
		editor_sprite_frames = value
		remove_child(get_child(0))
		if(editor_sprite_frames == null): #Static sprite
			var sprite_2d : Sprite2D = Sprite2D.new()
			sprite_2d.texture = editor_sprite
			add_child(sprite_2d)
			move_child(sprite_2d, 0)
		else: #Spritesheet
			var anim_sprite_2d : AnimatedSprite2D = AnimatedSprite2D.new()
			anim_sprite_2d.sprite_frames = editor_sprite_frames
			anim_sprite_2d.play("default")
			add_child(anim_sprite_2d)
			move_child(anim_sprite_2d, 0)
	get:
		return editor_sprite_frames
@export var editor_collision_horizontal : float = 0.0
@export var editor_collision_vertical : float = 0.0
@export var editor_initial_velocity_x : float = 0.0
@export var editor_initial_velocity_y : float = 0.0
@export var editor_acceleration_x : float = 0.0
@export var editor_acceleration_y : float = 0.0

#Override Variables
var acceleration_x : float = 0.0
var acceleration_y : float = 0.0

var damage : float = 0.0 #how much damage the object will deal to something it collides with

var score_value : int = 0 #how much score is gained upon the entity's death

var fire_pattern : Array[EntitySpawnWave] = [] #List of EntitySpawnWaves
var fire_cooldowns : Array[float] = []

var collision_team : int = 0 #0 for player, 1 for enemy
var is_a_bullet : bool = false
var collide_with_bullets : bool = true
var collide_with_own_team : bool = false

var collision_size_x : float = 0.0 #how far the collider extends out to the left and right from centre
var collision_size_y : float = 0.0 #how far the collider extends up and down from centre

var sprite : Texture2D = preload("res://icon.svg")
var spritesheet : SpriteFrames = preload("res://Assets/CharacterSprites/SpriteFrames/TestFrames.tres")

var oob_time_limit : float = 0.0 #How long an object can be out of bounds, if this is negative then no limit is applied



#Initilisation
func _init(initial_position_x: float = 0.0, initial_position_y: float = 0.0, source_entity: GameEntity = null) -> void:
	collided_entities.append(source_entity)
	position.x = initial_position_x
	position.y = initial_position_y


# Called when the node enters the scene tree for the first time.
func _ready() -> void: #override this for zeke projectiles to have randomised spread
	if(spritesheet == null): #Static sprite
		var sprite_2d : Sprite2D = Sprite2D.new()
		sprite_2d.texture = sprite
		add_child(sprite_2d)
	else: #Spritesheet
		var anim_sprite_2d : AnimatedSprite2D = AnimatedSprite2D.new()
		anim_sprite_2d.sprite_frames = spritesheet
		anim_sprite_2d.play("default")
		add_child(anim_sprite_2d)
	
	
	if(Engine.is_editor_hint()): #Dev tools
		remove_child(get_child(0))
		if(editor_sprite_frames == null): #Static sprite
			var sprite_2d : Sprite2D = Sprite2D.new()
			sprite_2d.texture = editor_sprite
			add_child(sprite_2d)
			move_child(sprite_2d, 0)
		else: #Spritesheet
			var anim_sprite_2d : AnimatedSprite2D = AnimatedSprite2D.new()
			anim_sprite_2d.sprite_frames = editor_sprite_frames
			anim_sprite_2d.play("default")
			add_child(anim_sprite_2d)
			move_child(anim_sprite_2d, 0)
		add_child(Line2D.new())
		get_child(1).closed = true
		get_child(1).width = 4
		for index in range(0,4):
			get_child(1).add_point(Vector2(10*index, 10*index))
		add_child(Line2D.new())
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Dev-tool stuff
	if(Engine.is_editor_hint()):
		_dev_tools(delta)
	
	
	#Actual game stuff
	_movement(delta)
	
	_despawn_check(delta)
	
	_lifetime_update(delta)
	
	_auto_fire(delta)


func _dev_tools(delta : float) -> void: #General dev tool stuff, for figuring stuff out in editor
	get_child(1).visible = show_bounds
	get_child(2).visible = show_trajectory
	
	if(show_bounds):
		get_child(1).points[0] = Vector2(-editor_collision_horizontal, -editor_collision_vertical)
		get_child(1).points[1] = Vector2(editor_collision_horizontal, -editor_collision_vertical)
		get_child(1).points[2] = Vector2(editor_collision_horizontal, editor_collision_vertical)
		get_child(1).points[3] = Vector2(-editor_collision_horizontal, editor_collision_vertical)
	if(show_trajectory):
		get_child(2).clear_points()
		var traj_pos_x : float = 0+dev_initial_pos.x-position.x
		var traj_pos_y : float = 0+dev_initial_pos.y-position.y
		var traj_vel_x : float = editor_initial_velocity_x
		var traj_vel_y : float = editor_initial_velocity_y
		for traj_index in range(0,trajectory_steps+1):
			get_child(2).add_point(Vector2(traj_pos_x, traj_pos_y))
			traj_pos_x += traj_vel_x+0.5*editor_acceleration_x
			traj_pos_y += traj_vel_y+0.5*editor_acceleration_y
			traj_vel_x += editor_acceleration_x
			traj_vel_y += editor_acceleration_y
	if(follow_trajectory):
		if(!follow_traj_previous_state):
			dev_initial_pos = position
		position.x = dev_initial_pos.x+dev_traj_timer*(editor_initial_velocity_x+0.5*dev_traj_timer*editor_acceleration_x)
		position.y = dev_initial_pos.y+dev_traj_timer*(editor_initial_velocity_y+0.5*dev_traj_timer*editor_acceleration_y)
		dev_traj_timer += delta
		if(dev_traj_timer > trajectory_steps):
			position = dev_initial_pos
			dev_traj_timer = 0
	elif(follow_traj_previous_state):
		position = dev_initial_pos
		dev_traj_timer = 0
	else:
		dev_initial_pos = position
		dev_traj_timer = 0
	follow_traj_previous_state = follow_trajectory
	return

func _movement(delta : float) -> void: #Movement over time
	position.x += delta*(velocity_x+0.5*delta*acceleration_x)
	position.y += delta*(velocity_y+0.5*delta*acceleration_y)
	velocity_x += delta*acceleration_x
	velocity_y += delta*acceleration_y

func _despawn_check(delta : float) -> void: #Despawning after too long out of bounds
	if(position.x+collision_size_x < 0 or position.x-collision_size_x > Global.screen_bounds[0] #Checks if object is within horizontal bounds
		or position.y+collision_size_y < -0.5*Global.screen_bounds[1] or position.y-collision_size_y > Global.screen_bounds[1]): #Checks if object is within vertical bounds, gives space above the visible area equal to 1/2 of the play area's height that is considered in bounds for spawning purposes
			oob_time_passed += delta
			if(oob_time_passed > oob_time_limit and oob_time_limit >= 0):
				if(!is_a_bullet and collision_team == 1 and position.y > Global.screen_bounds[1]): #Damages player if a non-bullet enemy gets past
					Global.player_health -= damage
				queue_free()
	else:
		oob_time_passed = 0.0

func _lifetime_update(delta : float) -> void: #Despawning after lifespan timer runs out
	if(lifetime > 0):
		lifetime -= delta
		if(lifetime < 0.5*delta):
			queue_free()

func _auto_fire(delta : float) -> void: #Firing bullets according to pattern
	if(fire_pattern.size() > 0 and fire_cooldowns.size() > 0 #checks there actually is any firing pattern
		and firing_index < fire_pattern.size() and firing_index < fire_cooldowns.size()): #checks that the index is in range (it will go out of range if runs out of loops)
		if(fire_pattern[firing_index] != null):
			firing_cooldown -= delta
			if(firing_cooldown <= 0.5*delta):
				if(spritesheet != null): 
					if(get_child(0).sprite_frames.get_animation_names().has("fire")): #runs firing animation if one is present
						get_child(0).play("fire")
						if(!get_child(0).animation_finished.is_connected(_fire_anim_finished)):
							get_child(0).animation_finished.connect(_fire_anim_finished)
				
				
				for spawn_index in range (0,fire_pattern[firing_index].entity_spawn_list.size()): #spawns the wave
					var spawn_entity_pos_x = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_position[0]
					var spawn_entity_pos_y = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_position[1]
					var spawn_entity : GameEntity = null
					if(fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_entity.new().is_a_bullet):
						var spawn_entity_vel_x = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_velocity[0]
						var spawn_entity_vel_y = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_velocity[1]
						var spawn_entity_acc_x = fire_pattern[firing_index].entity_spawn_list[spawn_index].acceleration[0]
						var spawn_entity_acc_y = fire_pattern[firing_index].entity_spawn_list[spawn_index].acceleration[1]
						var spawn_entity_team = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_team
						spawn_entity = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_entity.new(spawn_entity_pos_x+position.x, spawn_entity_pos_y+position.y, self, spawn_entity_vel_x, spawn_entity_vel_y, spawn_entity_acc_x, spawn_entity_acc_y, spawn_entity_team)
					else:
						spawn_entity = fire_pattern[firing_index].entity_spawn_list[spawn_index].spawn_entity.new(spawn_entity_pos_x+position.x, spawn_entity_pos_y+position.y, self)
					add_sibling(spawn_entity)
				
				firing_cooldown = fire_cooldowns[firing_index]
				#increment the firing index, or loop back around (if looping is enabled)
				if((firing_index < fire_pattern.size() and firing_index < fire_cooldowns.size()) or fire_loop_count == 0):
					firing_index += 1
				else: #looping back to start
					if(fire_loop_count > 0): #decrements amount of loops left if limited
						fire_loop_count -= 1
					firing_index = 0





#Taking damage
func _damage(damage_amount: float) -> void:
	health -= damage_amount
	if(health <= 0):
		if(spritesheet != null):
			if(get_child(0).animation != "death"):
				if(get_child(0).sprite_frames.get_animation_names().has("death")): #runs death animation if one is present
					if(get_child(0).sprite_frames.get_frame_count("death") > 0):
						get_child(0).play("death")
						if(!get_child(0).animation_finished.is_connected(queue_free)):
							get_child(0).animation_finished.connect(queue_free)
					else:
						queue_free()
				else:
					queue_free()
			else:
				return
		else:
			queue_free()
		Global.score += score_value


func _fire_anim_finished() -> void:
	get_child(0).play("default")
	get_child(0).animation_finished.disconnect(_fire_anim_finished)
