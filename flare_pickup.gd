extends Node2D

@export var num = 1

func _on_area_2d_body_entered(body):
	body.on_flare_picked(num)
	queue_free()
