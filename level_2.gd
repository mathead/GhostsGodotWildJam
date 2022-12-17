extends Node2D

var picked = false
var played = false

func _ready():
	get_node("/root/Main").set_text("Huh?! Didn't I just leave?       Why is it so dark? ... There's a flashlight in the bedroom")

func _physics_process(delta):
	if randf() < 0.03:
		get_node("House/EmisTileMap").modulate.r = randf()
	else:
		get_node("House/EmisTileMap").modulate.r = 0


func _on_flashlight_picked():
	get_node("/root/Main").set_text("Press Left Mouse Button to switch the flashlight on and off")
	picked = true

func _unhandled_input(event):
	if event.is_action_pressed("click") and picked and not played:
		get_node("/root/Main").set_text("The battery's dead. There are some in the bathroom.")
		%Battery.visible = true
		played = true


func _on_battery_picked():
	get_node("/root/Main").set_text("Good, let's get out of here")
	%Block.queue_free()
