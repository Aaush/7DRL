extends Area2D


var speed = 300

func _physics_process(delta):
	position += transform.x * speed * delta



func _on_Arrow_body_entered(body):
	if body.is_in_group("Player"):
		body.damage(3)
		queue_free()
	
