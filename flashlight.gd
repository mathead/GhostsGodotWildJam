extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$EmisPoly.polygon = $MedEmis.occluder.polygon
	$EmisPoly.scale *= 1.2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var r = Vector2.RIGHT.rotated(get_parent().rotation)
	$EmisPoly.modulate.g = (1+r.x) / 2
	$EmisPoly.modulate.b = (1+r.y) / 2

func set_charge(charge):
	$EmisPoly.modulate.r = charge
	visible = charge > 0
