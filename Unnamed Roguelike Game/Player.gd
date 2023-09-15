extends CharacterBody2D

@export var player_speed = 300.0

@onready var player_health = 100

var enemies_in_hitbox = []

@export var Arrow : PackedScene

@onready var arrow_direction = $"Projectile Spawn"

func _physics_process(delta):
	
	var input_direction = Input.get_vector("left", "right", "up", "down").normalized()
	
	velocity = input_direction * player_speed * delta
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	move_and_collide(velocity)


func _player_death():
	if player_health <= 0:
		self.queue_free()

func shoot():
	var arrow = Arrow.instantiate()
	arrow_direction.look_at(get_global_mouse_position())
	owner.add_child(arrow)
	arrow.transform = $"Projectile Spawn".global_transform



func _player_hit():
	player_health -= 10
	_player_death()
	modulate.a = 0.5
	modulate.b = 0
	modulate.g = 0
	$Hurt_Timer.start()
	#Psuedo Hurt animation to show when I-Frames start/end
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	var tween3 = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1, 1.5)
	tween2.tween_property(self, "modulate:b", 1, 1)
	tween3.tween_property(self, "modulate:g", 1, 1)


func _on_hurtbox_body_entered(body):
	if "Enemy" in body.name:
		if enemies_in_hitbox.is_empty():
			enemies_in_hitbox.push_back(body.name)
		if modulate.a == 1:
			_player_hit()


func _on_hurtbox_body_exited(body):
	if "Enemy" in body.name:
		enemies_in_hitbox.pop_back()


func _on_hurt_timer_timeout():
	modulate.a = 1
	modulate.b = 1
	modulate.g = 1
	if !enemies_in_hitbox.is_empty():
		_player_hit()
