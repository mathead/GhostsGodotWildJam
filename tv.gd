extends Node2D

@export var dir = Vector2.DOWN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Emis.modulate.r = randf() * 0.4 + 0.05
	$Emis.modulate.g = (1+dir.x) / 2
	$Emis.modulate.b = (1+dir.y) / 2
