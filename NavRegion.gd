extends NavigationRegion2D

func _ready():
	await get_tree().physics_frame
	await get_tree().physics_frame
	if $Area2D.get_overlapping_bodies():
		queue_free()
	$Area2D.queue_free()

func _process(delta):
	var light = get_node("/root/Main").light_at(self)
	#$Icon.modulate.a = 1-sample.a
	travel_cost = pow(light, 1.0)+0.001
#	enabled = light < 0.5
#	$Icon.visible = enabled
