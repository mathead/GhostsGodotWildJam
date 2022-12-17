extends Area2D


func _on_body_entered(body):
	get_node("/root/Main").call_deferred("next_level")
