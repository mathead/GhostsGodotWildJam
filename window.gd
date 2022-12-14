extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randf() < 0.02:
		$Icon.modulate = Color.WHITE
		$Emis.modulate = Color.WHITE
	else:
		$Icon.modulate = Color.LIGHT_BLUE
		$Emis.modulate = Color.BLACK
