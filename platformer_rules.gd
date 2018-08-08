extends Node

var player_children = []
var is_over = false

func _ready():
	var player = load('res://player.tscn')
	var player_instance = player.instance()
	
	var start = get_parent().get_node('root/start')
	var start_pos = start.get_global_position()
	
	player_instance.set_name('player0')
	player_instance.set_global_position(Vector2(start_pos.x + 30, start_pos.y))
	player_children.append(player_instance)
	add_child(player_instance)
	set_physics_process(true)
	
func _physics_process(delta):
	if not player_children:
		is_over = true
		game_over()
		
	for child in player_children:
		if child.get_is_hit():
			if child.get_player_scale() > 0.25:
				var cur_scale = child.get_player_scale()
				var new_scale
				if cur_scale in [1.0, 0.5]:
					new_scale = child.get_player_scale() / 2.0
				else:
					new_scale = child.get_player_scale() - 0.25
				
				child.set_is_hit(false)
				child.set_player_scale(new_scale)
				
				var new_player = load('res://player.tscn')
				var new_player_instance = new_player.instance()
				var new_player_name = 'player' + str(len(player_children))
				print(child.get_global_position())
				var timer = Timer.new()
				timer.one_shot = true
				timer.wait_time = 1
				timer.start()
				
				var new_player_pos = Vector2(child.get_global_position().x + 50, child.get_global_position().y)
				print(new_player_pos)
				new_player_instance.set_name(new_player_name)
				new_player_instance.set_global_position(new_player_pos)
				new_player_instance.set_player_scale(cur_scale - new_scale)
				
				player_children.append(new_player_instance)
				add_child(new_player_instance)
			else:
				child.set_is_dead()
				player_children.erase(child)
				
		if child.get_is_able_to_merge():
			var other_player = child.get_other_player()
			child.set_is_able_to_merge(false)
			
			var cur_scale = child.get_player_scale()
			var other_scale = other_player.get_player_scale()
			print(cur_scale)
			print(other_scale)
			print()
			child.set_player_scale(cur_scale + other_scale)
			
			other_player.set_is_dead()
			player_children.erase(other_player)
			
func game_over():
	print('well, rip')
	is_over = false
	set_physics_process(false)