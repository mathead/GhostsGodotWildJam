extends RigidBody2D

const SPEED = 10000.0
var flare_scene = preload("res://flare.tscn")

func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if direction:
#		velocity = direction * SPEED
		apply_central_impulse(delta*direction*SPEED)
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED/10)
#		velocity.y = move_toward(velocity.y, 0, SPEED/10)

#	move_and_slide()
	
	$Node2D.look_at(get_global_mouse_position())
	var dir = (get_global_mouse_position() - global_position)
	$MainCamera.offset = lerp($MainCamera.offset, dir / 20, 0.05)
	$MainCamera.rotation = lerp($MainCamera.rotation, (dir.x)/10000, 0.05)

func _unhandled_input(event):
	if event.is_action_pressed("rightclick"):
		var flare: RigidBody2D = flare_scene.instantiate()
		get_parent().add_child(flare)
		flare.global_position = global_position
		flare.apply_central_impulse((get_global_mouse_position()-global_position)*4.6)
		flare.angular_velocity = randf() * 30 - 30
		
	if event.is_action_pressed("click"):
		%Flashlight.visible = not %Flashlight.visible
