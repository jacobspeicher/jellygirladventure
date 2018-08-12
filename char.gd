extends KinematicBody2D

export (int) var run_speed = 225
export (int) var jump_speed = -415
export (int) var bounce_back_force = 20
export (int) var gravity = 1200
export (float) var size = 1.0
export (bool) var able_to_merge = false
export (bool) var hit = false
export (bool) var dead = false
export (bool) var collided = false

var velocity

var jumping = false

var on_wall = false
var on_floor = false

var wall_jumping = false
var wall_jump_speed = 0

var initial_char_pos

var hit_object
var wall_jump_timer
var input = false

var direction = 'none'
var last_direction = 'none'
var jump_direction = 'none'
var anim = 'idle'

func _ready():
	velocity = Vector2()
	initial_char_pos = get_global_position()
	wall_jump_timer = Timer.new()
	wall_jump_timer.set_timer_process_mode(0)
	wall_jump_timer.set_wait_time(0.5)
	wall_jump_timer.set_one_shot(true)
	add_child(wall_jump_timer)
	
	set_physics_process(true)
		
func _physics_process(delta):
	if not get_disabled_input():
		get_input()

	velocity = move_and_slide(velocity, Vector2(0, -1), 5, 10)
	velocity.y += gravity * delta
	
	if is_on_floor():
		on_floor = true
		
	if jumping and on_floor:
		jumping = false
	if wall_jump_timer.is_stopped():
		wall_jumping = false
	else:
		velocity.x = wall_jump_speed

	if direction == 'left':
		get_node('AnimatedSprite').set_flip_h(true)
		anim = 'run'
	if direction == 'right':
		get_node('AnimatedSprite').set_flip_h(false)
		anim = 'run'
	if direction == 'none':
		anim = 'idle'
	
	get_node('AnimatedSprite').play(anim)
	
	var collision = []
	if not collided:
		for i in range(get_slide_count()):
			collision.append(get_slide_collision(get_slide_count() - 1))
	if collision :
		for col in collision:
			hit_object = col.collider
			var hit_layer = hit_object.get_collision_layer()

			if hit_layer == 1:
				set_is_able_to_merge(true)

			if hit_layer == 2:
				on_floor = true
				if wall_jump_timer.get_time_left() > 0:
					wall_jump_timer.stop()

			if hit_layer == 4:
				if not on_floor:
					print('time to wall jump')
					wall_jump_timer.stop()
					on_wall = true
				if on_floor:
					print('on the floor too tho')

			if hit_layer == 8:
				pass

			if hit_layer == 16:
				pass

			if hit_layer == 32:
				disable_input(true)
				velocity.y = -415
#				velocity = velocity.bounce(col.get_normal()) * bounce_back_force

				if direction == 'left' or last_direction == 'left':
					velocity.x = 200
				if direction == 'right' or last_direction == 'right':
					velocity.x = -200
				print(velocity)
				collided = true

			if hit_layer == 64:
				pass
	if on_wall:
		gravity = 0
		velocity.y = 0
		
	if collided:
		set_collision_mask_bit(0, false)
		set_collision_layer_bit(0, false)
		set_collision_layer_bit(7, true)
		get_node('AnimatedSprite').modulate = Color(10, 1, 1, 0.5)
		velocity.x *= 0.99
		if (velocity.x < 95 and velocity.x > 0) or (velocity.x > -90 and velocity.x < 0):
			velocity.x = 0
		if (velocity.x < 10 and velocity.x > -10):
			get_node('AnimatedSprite').modulate = Color(1, 1, 1, 1)
			collided = false
			disable_input(false)
			set_is_hit(true)
	
func get_input():
	if velocity.x > 0 or velocity.x < 0:
		velocity.x *= 0.5
		
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed('jump')

	if jump and on_floor:
		on_floor = false
		jumping = true
		velocity.y = jump_speed

	if jump and on_wall and not on_floor:
		wall_jumping = true
		on_wall = false
		if last_direction == 'left':
			jump_direction = 'right'
			velocity.y = jump_speed
			wall_jump_speed = run_speed * 2
			velocity.x = wall_jump_speed
			wall_jump_timer.start()
		if last_direction == 'right':
			jump_direction = 'left'
			velocity.y = jump_speed
			wall_jump_speed = -run_speed * 2
			velocity.x = wall_jump_speed
			wall_jump_timer.start()
		gravity = 1200

	if not on_wall:
		if right:
			direction = 'right'
			last_direction = 'right'
			if direction != jump_direction and wall_jumping:
				pass
			else:
				velocity.x = run_speed
		elif left:
			direction = 'left'
			last_direction = 'left'
			if direction != jump_direction and wall_jumping:
				pass
			else:
				velocity.x = -run_speed
		else:
			direction = 'none'

func get_player_scale():
	return size
	
func get_is_hit():
	return hit

func get_is_able_to_merge():
	return able_to_merge
	
func get_disabled_input():
	return input
	
func get_other_player():
	if able_to_merge:
		return hit_object
			
func set_player_scale(new_scale):
	size = new_scale
	
func set_is_hit(new_hit):
	hit = new_hit
	
func set_is_able_to_merge(new_able_to_merge):
	able_to_merge = new_able_to_merge
	
func disable_input(new_input):
	input = new_input
	
func set_is_dead():
	set_physics_process(false)
	queue_free()

func knockback(normal):
	set_is_knockback(true)
	velocity = -velocity
	while velocity != Vector2(0, 0):
		print(velocity)
		move_and_slide(velocity)
		velocity *= 0.99
