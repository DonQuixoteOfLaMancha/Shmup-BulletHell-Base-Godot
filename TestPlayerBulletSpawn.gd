extends EntitySpawnWave

class_name TestPlayerBulletSpawn

func _init() -> void:
	entity_spawn_list = [GameEntitySpawn.new(Bullet, [50, 50], [0,-100], [20,0])]
