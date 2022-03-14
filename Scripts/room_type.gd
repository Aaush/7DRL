extends Node2D


export var type : int = 0

onready var variants := get_node("Variants").get_children()
onready var spawns := get_node("Spawns")

var spawn_point = null

export var _is_start := false
export var _is_end := false

var _enemy := preload("res://Scenes/Enemy.tscn")

var player = null

var _rng := RandomNumberGenerator.new()

func _ready():
	_rng.randomize()
	
	var vari : int = _rng.randi_range(0, variants.size() - 1)
	
	if !_is_start and !_is_end:
		variants[vari].visible = true
		variants[vari].collision_mask = 2
		variants[vari].collision_layer = 2
	
	if _is_start:
		spawn_point = get_node("Spawn Point")
		
	yield(get_tree().create_timer(5), "timeout")
	if !_is_start and !_is_end:
		var b = _enemy.instance()
		get_parent().get_parent().get_child(3).call_deferred("add_child", b)
		b.global_transform = spawns.global_transform
		b.get_player(player)

func set_player(_player):
	player = _player



func _on_End_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene("res://Scenes/Start.tscn")
