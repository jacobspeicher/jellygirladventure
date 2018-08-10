extends KinematicBody2D

export (int) var run_speed = 225
export (int) var jump_speed = -415
export (int) var bounce_back_force = 20
export (int) var gravity = 1200
export (float) var size = 1.0
export (bool) var able_to_merge = false
export (bool) var hit = false
export (bool) var dead = false

var velocity

var jumping
var wall_jumping
var wall_stuck = false

var on_floor = false
var on_wall = false

var initial_char_pos

var hit_object
var timer
var start_knockback = false
var direction = 'none'

func _ready():
	velocity = Vector2()
	jumping = false
	initial_char_pos = get_global_position()
	start_knockback = false
	
	set_physics_process(true)
		
func _physics_process(delta):
	if not get_is_knockback():
		get_input()

	velocity = move_and_slide(velocity, Vector2(0, -1))

	if is_on_wall() and not is_on_floor():
		wall_stuck = true
		jumping = false
	else:
		wall_stuck = false
	
	if not wall_stuck:
		velocity.y += gravity * delta
		
	if jumping and is_on_floor():
		jumping = false

	if wall_jumping:
		if is_on_wall():
			wall_stuck = true
			wall_jumping = false
		if is_on_floor():
			wall_jumping = false

	if direction == 'left':
		get_node('Sprite').set_flip_h(true)
	if direction == 'right':
		get_node('Sprite').set_flip_h(false)
	
	var collision = []
	for i in range(get_slide_count()):
		collision.append(get_slide_collision(get_slide_count() - 1))
	if collision:
		#print(get_slide_count())
		for col in collision:
			hit_object = col.collider
			var hit_layer = hit_object.get_collision_layer()
			#print(hit_layer)

			if hit_layer == 1:
				set_is_able_to_merge(true)

			if hit_layer == 2:
				on_floor = true

			if hit_layer == 4:
				on_wall = true

			if hit_layer == 8:
				pass

			if hit_layer == 16:
				pass

			if hit_layer == 32:
				print('done been hit')
				set_is_hit(true)
				velocity = velocity.bounce(col.get_normal()) * bounce_back_force
				print(get_collision_mask_bit(6))
				set_collision_mask_bit(6, false)

			if hit_layer == 64:
				pass
	
func get_input():
	if velocity.x > 0 or velocity.x < 0:
		velocity.x *= 0.5
		
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed('jump')

	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed

	if jump and wall_stuck and not is_on_floor():
		wall_jumping = true
		wall_stuck = false
		velocity.y = jump_speed
		if direction == 'left':
			velocity.x = -jump_speed * 2
		if direction == 'right':
			velocity.x = jump_speed * 2

	if not is_on_wall():
		if right:
			direction = 'right'
			velocity.x = run_speed
		elif left:
			direction = 'left'
			velocity.x = -run_speed
		else:
			direction = 'none'

func get_player_scale():
	return size
	
func get_is_hit():
	return hit

func get_is_able_to_merge():
	return able_to_merge
	
func get_is_knockback():
	return start_knockback
	
func get_other_player():
	if able_to_merge:
		return hit_object
			
func set_player_scale(new_scale):
	size = new_scale
	
func set_is_hit(new_hit):
	hit = new_hit
	
func set_is_able_to_merge(new_able_to_merge):
	able_to_merge = new_able_to_merge
	
func set_is_knockback(new_knockback):
	start_knockback = new_knockback
	
func set_is_dead():
	remove_child(get_node("CollisionShape2D"))
	set_physics_process(false)
	queue_free()

func knockback(normal):
	set_is_knockback(true)
	velocity = -velocity
	while velocity != Vector2(0, 0):
		print(velocity)
		move_and_slide(velocity)
		velocity *= 0.99