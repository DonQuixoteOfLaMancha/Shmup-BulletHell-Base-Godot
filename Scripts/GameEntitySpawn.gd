class_name GameEntitySpawn

#Variables
var spawn_entity = null #Class of the spawn, not an instanced one of it
var spawn_position : Array[float] = [0,0]
var spawn_velocity : Array[float] = [0,0]
var acceleration : Array[float] = [0,0]
var spawn_team : int = 0

func _init(entity_class, position: Array[float], velocity : Array[float] = [0,0], accel : Array[float] = [0,0], team : int = 0):
	spawn_entity = entity_class
	spawn_position = position
	spawn_velocity = velocity
	acceleration = accel
	spawn_team = team
