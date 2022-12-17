extends Node2D

signal picked

func _on_area_2d_body_entered(body):
	emit_signal("picked")
	body.has_flashlight = true
	queue_free()
