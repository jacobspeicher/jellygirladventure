extends KinematicBody2D

export (int) var run_speed = 225
export (int) var jump_speed = -415
export (int) var bounce_back_force = 300
export (int) var gravity = 1200
export (float) var size = 1.0
export (bool) var able_to_merge = false
export (bool) var hit = false
export (bool) var dead = false

var velocity
var jumping
var initial_char_pos
var hit_object

func _ready():
	velocity = Vector2()
	jumping = false
	initial_char_pos = get_global_position()
	set_physics_process(true)
		
func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	
	if get_slide_count() > 0:
		var collision = get_slide_collision(get_slide_count() - 1)
		hit_object = collision.collider
		if hit_object.get_collision_layer() == 1:
			able_to_merge = true
		if hit_object.get_collision_layer() == 32:
			set_is_hit(true)
			velocity += collision.get_normal() * bounce_back_force
			
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed('jump')

	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed

	if not is_on_wall():
		if right:
			velocity.x += run_speed
		if left:
			velocity.x -= run_speed

func get_player_scale():
	return size
	
func get_is_hit():
	return hit

func get_is_able_to_merge():
	return able_to_merge
	
func get_other_player():
	if able_to_merge:
		return hit_object
			
func set_player_scale(new_scale):
	size = new_scale
	set_scale(Vector2(new_scale, new_scale))
	
func set_is_hit(new_hit):
	hit = new_hit
	
func set_is_able_to_merge(new_able_to_merge):
	able_to_merge = new_able_to_merge
	
func set_is_dead():
	remove_child(get_node("CollisionShape2D"))
	set_physics_process(false)
	queue_free()