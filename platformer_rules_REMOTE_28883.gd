extends Node

var player_children = []
var is_over = false
var timer
var character_types = {1.0: 'res://player100.tscn', 0.75: 'res://player75.tscn', 0.50: 'res://player50.tscn', 0.25: 'res://player25.tscn'}

func _ready():
	var player = load('res://player100.tscn')
	var player_instance = player.instance()
	
	var start = get_parent().get_node('root/start')
	var start_pos = start.get_global_position()
	
	player_instance.set_name('player0')
	player_instance.set_global_position(Vector2(start_pos.x + 30, start_pos.y))
	player_children.append(player_instance)
	add_child(player_instance)
	
	timer = Timer.new()
	timer.wait_time = 1
	timer.one_shot = true
	
	set_physics_process(true)
	
func _physics_process(delta):
	if not player_children:
		is_over = true
		game_over()
		
	for child in player_children:
		if child.get_is_hit():
			if child.get_player_scale() > 0.25:
				if not child.get_is_knockback():
					split(child)
			else:
				kill(child)
		if child.get_is_able_to_merge():
			merge(child)

func split(character):
	var cur_scale = character.get_player_scale()
	var new_scale
	if cur_scale in [1.0, 0.5]:
		new_scale = character.get_player_scale() / 2.0
	else:
		new_scale = character.get_player_scale() - 0.25

	var new_player = load(character_types[cur_scale - new_scale])
	var new_player_instance = new_player.instance()
	var new_player_name = 'player' + str(len(player_children))

	var new_child = load(character_types[new_scale])
	var new_child_instance = new_child.instance()
	var new_child_name = character.get_name()

	var new_player_pos = Vector2(character.get_global_position().x + 100, character.get_global_position().y)
	var new_child_pos = character.get_global_position()

	new_player_instance.set_name(new_player_name)
	new_player_instance.set_global_position(new_player_pos)
	new_player_instance.set_player_scale(cur_scale - new_scale)

	new_child_instance.set_name(new_child_name)
	new_child_instance.set_global_position(new_child_pos)
	new_child_instance.set_player_scale(new_scale)

	kill(character)

	player_children.append(new_player_instance)
	player_children.append(new_child_instance)

	add_child(new_player_instance)
	add_child(new_child_instance)

func merge(character):
	var other_player = character.get_other_player()
	character.set_is_able_to_merge(false)
	print(other_player)
	print(weakref(other_player).get_ref())
	if not weakref(other_player).get_ref() == null:
		var cur_scale = character.get_player_scale()
		var other_scale = other_player.get_player_scale()
		print(cur_scale)
		print(other_scale)
		var new_scale = cur_scale + other_scale

		var new_child = load(character_types[new_scale])
		var new_child_instance = new_child.instance()
		var new_child_name = character.get_name()
		var new_child_pos = other_player.get_global_position()

		new_child_instance.set_name(new_child_name)
		new_child_instance.set_global_position(new_child_pos)
		new_child_instance.set_player_scale(new_scale)

		kill(character)
		kill(other_player)

		player_children.append(new_child_instance)
		add_child(new_child_instance)

func kill(character):
	character.set_is_dead()
	player_children.erase(character)
			
func game_over():
	print('well, rip')
	is_over = false
	set_physics_process(false)