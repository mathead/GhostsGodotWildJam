extends RigidBody2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Emis.modulate.r = randf() + 0.5
