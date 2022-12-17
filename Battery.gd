extends Node2D

@export var charge = 1.0
signal picked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	emit_signal("picked")
	body.on_battery_picked(charge)
	queue_free()
