extends EntitySpawnWave

class_name TestBombSpawn

func _init() -> void:
	entity_spawn_list = [GameEntitySpawn.new(Bomb, [0, 0])]
