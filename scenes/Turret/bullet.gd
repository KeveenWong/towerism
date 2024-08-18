extends RigidBody2D

func _on_body_entered(body):
	if body.is_in_group("targets"):
		body.hit()
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
