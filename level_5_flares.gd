extends Node2D

var played = false

func _ready():
	get_node("/root/Main").set_text("Crap, my flashlight broke")


func _on_flare_picked():
	if not played:
		get_node("/root/Main").set_text("Press Right Mouse Button to through a flare to the cursor")
		played = true
