class_name GameEntitySpawn

#Variables
var spawn_entity = null #Class of the spawn, not an instanced one of it
var spawn_position : Array[int] = [0,0]

func _init(entity_class, position: Array[int]):
	spawn_entity = entity_class
	spawn_position = position
