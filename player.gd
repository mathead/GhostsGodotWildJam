extends RigidBody2D

var flare_scene = preload("res://flare.tscn")
const SPEED = 10000.0
@export var charge = 1.0
@export var discharge_secs = 30.0
@onready var charge_bar = get_node("/root/Main/%Battery")
var dead = false
@export var flashlight_on = true

func _process(delta):
	if flashlight_on:
		charge -= delta * (1/discharge_secs)
		charge = max(0, charge)
		charge_bar.value = charge
		%Flashlight.set_charge(charge)
	else:
		%Flashlight.set_charge(0)

func _physics_process(delta):
	if dead:
		$MainCamera.zoom *= 1 + 0.2*delta
		return
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
	if dead: return
	if event.is_action_pressed("rightclick"):
		var flare: RigidBody2D = flare_scene.instantiate()
		get_parent().add_child(flare)
		flare.global_position = global_position
		flare.apply_central_impulse((get_global_mouse_position()-global_position)*4.6)
		flare.angular_velocity = randf() * 30 - 30
		
	if event.is_action_pressed("click"):
		flashlight_on = not flashlight_on
		
func on_battery_picked(c):
	charge = min(1, charge+c)


func _on_body_entered(body):
	if dead: return
	if body.is_in_group("ghosts"):
		dead = true
		%DeathIcon.visible = true
		await get_tree().create_timer(3).timeout
		get_node("/root/Main").load_level()
		
