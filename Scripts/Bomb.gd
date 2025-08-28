extends GameEntity

class_name Bomb

var explosion_delay : float = 0.0
var clear_timer : float = 0.0

var explosion_img : Texture2D = null
var explosion_animation : SpriteFrames = null

func _init(initial_position_x: float = 0.0, initial_position_y: float = 0.0, source_entity: GameEntity = null) -> void:
	super(initial_position_x, initial_position_y, source_entity)
	
	health = 10000
	damage = 10000


func _process(delta: float) -> void:
	explosion_delay -= delta
	if(explosion_delay <= 0.5*delta):
		_explode()
		clear_timer -= delta
		if(clear_timer <= 0.5*delta && explosion_animation == null):
			queue_free()

func _explode():
	get_child(0).queue_free()
	if(explosion_animation == null):
		var sprite2d = Sprite2D.new()
		sprite2d.texture = explosion_img
		if(explosion_img != null):
			sprite2d.scale = Vector2(explosion_img.get_width()/Global.screen_bounds[0],explosion_img.get_height()/Global.screen_bounds[1])
		add_child(sprite2d)
	else:
		var anim_sprite2d = AnimatedSprite2D.new()
		anim_sprite2d.sprite_frames = explosion_animation
		if(explosion_animation.get_animation_names().has("default")): #runs animation if one is present
				if(explosion_animation.get_frame_count("default") > 0):
					anim_sprite2d.play("default")
					anim_sprite2d.animation_finished.connect(queue_free)
		add_child(anim_sprite2d)
	
	position = Vector2(Global.screen_bounds[0]/2, Global.screen_bounds[1]/2)
	scale = Vector2(Global.screen_bounds[0]/2, Global.screen_bounds[1]/2)
