extends EntitySpawnWave

class_name TestWave

func _init() -> void:
	entity_spawn_list = [GameEntitySpawn.new(TestEnemy, [50, 50]),GameEntitySpawn.new(TestEnemy, [300, 450])]
