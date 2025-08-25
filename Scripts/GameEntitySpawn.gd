class_name GameEntitySpawn

#Variables
var spawn_entity : GameEntity = null
var spawn_position : Array[int] = [0,0]

func _init(entity: GameEntity, position: Array[int]):
	spawn_entity = entity
	spawn_position = position
