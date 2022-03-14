extends Node2D


signal path_completed
signal full_completed
signal send_player(player)

export(Array, PackedScene) var _rooms = null # index 0 --> LR index 1 --> LRB index 2 --> LRT index 3 --> LRTB
export(PackedScene) var _end_room = preload("res://Scenes/Rooms/End.tscn")
export(PackedScene) var _player = preload("res://Scenes/Player.tscn")
export(PackedScene) var _enemy = preload("res://Scenes/Enemy.tscn")

var _rng = RandomNumberGenerator.new()
var _grid := {}
var _room_size := 256
var _direction = 0
var _stop_gen := false
var down_counter := 0
var timeout := false
var player = null

export var _grid_size := Vector2(4, 4)

export(int) var min_x = 0
export(int) var min_y = 0
export(int) var max_x = 0

onready var parent := get_parent().get_node("Room Holder")
onready var player_parent := get_parent().get_node("Player Holder")
onready var timer := $Timer

var _last : Node2D
var _last_path : Node2D

func _ready() -> void:
	_rng.randomize()
	
	timer.start()
	
	make_grid(_grid_size)
	
	var _start_pos = _rng.randi_range(0, _grid_size.x-1)
	position = Vector2(_start_pos * _room_size, 0)
	add_instance(4)
	
	var p = _player.instance()
	player_parent.call_deferred("add_child", p)
# warning-ignore:integer_division
# warning-ignore:integer_division
	p.position = Vector2(position.x + _room_size/2, position.y +  _room_size/2)
	
	player = p
# warning-ignore:return_value_discarded
	connect("full_completed", p, "let_move")
# warning-ignore:return_value_discarded
	connect("full_completed", self, "add_end_room")
	
# warning-ignore:return_value_discarded
	_grid.erase(Vector2(position.x / _room_size, position.y / _room_size))
	
	print(position)
	
	_direction = _rng.randi_range(1, 5)
	

func _move() -> void:
	if (_direction == 1 or _direction == 2): #move right
		if (position.x < max_x):
			down_counter = 0
			var _new_pos := Vector2(position.x + _room_size, position.y)
			position = _new_pos
			var type = _rng.randi_range(0, 3)
			add_instance(type)
# warning-ignore:return_value_discarded
			_grid.erase(Vector2(position.x / _room_size, position.y / _room_size))
			_direction = _rng.randi_range(1, 5)
			if _direction == 3:
				_direction = 2
			elif _direction == 4:
				_direction = 5
		else: _direction = 5
	elif(_direction == 3 or _direction == 4): #move left
		if(position.x > min_x):
			down_counter = 0
			var _new_pos := Vector2(position.x - _room_size, position.y)
			position = _new_pos
			var type = _rng.randi_range(0, 3)
			add_instance(type)
# warning-ignore:return_value_discarded
			_grid.erase(Vector2(position.x / _room_size, position.y / _room_size))
			_direction = _rng.randi_range(3, 5)
		else: _direction = 5
	elif (_direction == 5): #move down
		down_counter += 1
		if(position.y < min_y):
			if(_last.type != 1 or _last.type != 3 or _last.type != 4):
				if (down_counter >= 2):
					_last.queue_free()
					add_instance(3)
				else:
					_last.queue_free()
					var type = _rng.randi_range(1, _rooms.size()-2)
					if type == 2: type = 1
					add_instance(type)
					_direction = _rng.randi_range(3, 5)
			
			var _new_pos := Vector2(position.x, position.y + _room_size)
			position = _new_pos
			
			var type = _rng.randi_range(2, 3)
			add_instance(type)
# warning-ignore:return_value_discarded
			_grid.erase(Vector2(position.x / _room_size, position.y / _room_size))
			
			_direction = _rng.randi_range(1, 5)
		else:
			_stop_gen = true;
			print("Path Generation Completed")

func add_side_rooms():
	_last_path = _last
	
	for pos in _grid:
		var type = _rng.randi_range(0, 3)
		position = pos * _room_size
		yield(get_tree().create_timer(0.125), "timeout")
		add_instance(type)
	emit_signal("full_completed")
	print("Full Generation Completed")

func add_instance(type : int):
	var d = _rooms[type].instance()
	parent.add_child(d)
	d.position = position
	_last = d
	
	connect("send_player", d, "set_player")
	

func make_grid(vector : Vector2):
	for x in vector.x:
		for y in vector.y:
			_grid[Vector2(x, y)] = 0

func add_room():
	if !_stop_gen:
		_move()
		timer.start()
	else:
		if (!timeout):
			var rooms_name := []
			for child in get_parent().get_node("Room Holder").get_children():
				rooms_name.append(child.name)
			print(rooms_name)
			emit_signal("path_completed")
			add_side_rooms()
			timeout = true

func add_end_room():
	position = _last_path.position
	_last_path.queue_free()
	
	var d = _end_room.instance()
	parent.add_child(d)
	d.position = position
	_last = d
	print( d.name + "added at", position)
	emit_signal("send_player", player)
