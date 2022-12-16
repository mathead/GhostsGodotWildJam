extends Node2D


func _physics_process(delta):
	if randf() < 0.03:
		get_node("House/EmisTileMap").modulate.r = randf()
	else:
		get_node("House/EmisTileMap").modulate.r = 0
