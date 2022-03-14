extends KinematicBody2D


export(PackedScene) var _fireball = preload("res://Scenes/Fireball.tscn")

export var speed := 100
export var friction := 0.18

onready var weapon := get_node("Holder/Weapon")
onready var camera := get_node("Camera2D")
onready var holder := get_node("Holder")

var velocity := Vector2.ZERO
var can_move := false
var is_facing_right := false

var health = 25

func _ready():
	owner = get_parent()

func _physics_process(delta):
	if health <= 0:
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
	
	if can_move:
		var direction := Vector2(
			Input.get_action_strength("left") - Input.get_action_strength("right"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
		
		if direction.length() > 1.0:
			direction = direction.normalized()
		
		var _del = delta
		
		var target_direction := direction * speed
		velocity += (target_direction - velocity) * friction
		
		velocity = move_and_slide(velocity)
		
		if (Input.is_action_just_pressed("shoot")):
			shoot()
	
	set_direction()

func set_direction():
	var sx = get_global_mouse_position() - global_position
	
	weapon.look_at(get_global_mouse_position())
	weapon.rotation = wrapf(fposmod(weapon.rotation, 2 * PI), -PI, PI)
	weapon.rotation = clamp(weapon.rotation, -PI/2, PI/2)
	
	if sx.x > 0:
		holder.scale.x = -1
	elif sx.x <= 0:
		holder.scale.x = 1
	
func damage(dmg :int):
	health -= dmg

func shoot():
	var b = _fireball.instance()
	owner.add_child(b)
	b.transform = weapon.get_child(0).global_transform

func let_move():
	can_move = true
