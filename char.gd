extends KinematicBody2D

export (int) var run_speed = 100
export (int) var jump_speed = -400
export (int) var gravity = 1200

var velocity = Vector2()
var jumping = false
var initial_char_pos = get_global_position()

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')

	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed

	if not is_on_wall():
		if right:
			velocity.x += run_speed
		if left:
			velocity.x -= run_speed
		
func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and is_on_floor():
		jumping = false
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if get_slide_count() > 0:
		var hit = get_slide_collision(get_slide_count() - 1).collider
		if hit.get_collision_layer() == 32:
			set_global_position(initial_char_pos)