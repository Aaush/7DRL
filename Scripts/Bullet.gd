extends Area2D


var speed = 300
export var is_arrow := false

func _physics_process(delta):
	if !is_arrow:
		position += transform.y * speed * delta
	else:
		position += transform.x * speed * delta

func _on_Fireball_body_entered(body):
	if body.is_in_group("Enemy"):
		body.damage(4)
		queue_free()
