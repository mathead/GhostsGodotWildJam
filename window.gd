extends Node2D

var on = 0.0
@onready var color = $Icon.modulate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if on > 0:
		$Icon.modulate = Color.WHITE
		if randf() < 0.1:
			$Emis.modulate.r = 1.0 + randf()
		on -= delta
	else:
		$Icon.modulate = color
		if randf() < 0.005:
			$Emis.modulate.r = 1.5 + randf()
			on = 0.5 + randf() * 0.3
		
	$Emis.modulate.r = lerp($Emis.modulate.r, 0.05, 0.5)
