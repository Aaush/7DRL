extends KinematicBody2D


var _play_in_sight := false
var _player_in_range := false
var can_fire := true
var _state = "Rest"
var _collision_mask := []
var health := 10
var speed = 150
var velocity := Vector2.ZERO

var player : KinematicBody2D

onready var weapon := get_node("Holder/Weapon")
onready var spawn := get_node("Holder/Weapon/spawn")

export(PackedScene) var arrow := preload("res://Scenes/Arrow.tscn")

func _physics_process(delta):
	sight_check()
	
	if health > 0:
		match _state:
			"Rest":
				pass
			"Attack":
				if can_fire:
					attack()
				else:
					pass
			"Search":
				search(delta)
	elif health <= 0:
		queue_free()
		
	move_and_slide(velocity)

func sight_check() -> void:
	if player != null:
		if _player_in_range:
			var space_state = get_world_2d().direct_space_state
			var signal_check = space_state.intersect_ray(position, player.position, [self], collision_mask)
			if signal_check:
				if signal_check.collider.is_in_group("Player"):
					_play_in_sight = true
					_state = "Attack"
				else:
					_play_in_sight = false
					_state = "Search"

func attack():
	weapon.look_at(player.position)
	
	can_fire = false
	var b = arrow.instance()
	get_parent().get_parent().call_deferred("add_child", b)
	b.transform = spawn.get_global_transform()
	yield(get_tree().create_timer(0.6), "timeout")
	can_fire = true

func search(delta):
	if _player_in_range:
		velocity = position.direction_to(player.position) * speed * delta

func damage(dmg : int):
	health -= dmg

func _on_Detection_Area_body_entered(body):
	if body.is_in_group("Player"):
		_player_in_range = true


func _on_Detection_Area_body_exited(body):
	if body.is_in_group("Player"):
		_player_in_range = false

func get_player(_player):
	player = _player
