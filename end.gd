extends Area2D

func _on_body_entered(body):
	get_node("/root/Main").set_text("You escaped! Thanks for playing!")
