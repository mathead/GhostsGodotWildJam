extends RigidBody2D

var flare_scene = preload("res://flare.tscn")
const SPEED = 10000.0
@export var charge = 1.0
@export var discharge_secs = 30.0
@export var num_flares = 0
@onready var charge_bar = get_node("/root/Main/%Battery")
@onready var flare_bar = get_node("/root/Main/%Flares")
var dead = false
@export var flashlight_on = true
@export var has_flashlight = true

func _process(delta):
	if flashlight_on and has_flashlight:
		charge -= delta * (1/discharge_secs)
		charge = max(0, charge)
		charge_bar.value = charge
		%Flashlight.set_charge(charge)
	else:
		%Flashlight.set_charge(0)
	charge_bar.visible = has_flashlight
	flare_bar.value = num_flares

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
			#footsteps sound
		if $Timer.time_left <=0:
			$SFXFootsteps.pitch_scale = randf_range(0.8,1.2)
			$SFXFootsteps.play()
			$Timer.start(0.8)

	
	$Node2D.look_at(get_global_mouse_position())
	var dir = (get_global_mouse_position() - global_position)
	$MainCamera.offset = lerp($MainCamera.offset, dir / 20, 0.05)
	$MainCamera.rotation = lerp($MainCamera.rotation, (dir.x)/10000, 0.05)

func _unhandled_input(event):
	if dead: return
	if event.is_action_pressed("rightclick") and num_flares > 0:
		var flare: RigidBody2D = flare_scene.instantiate()
		get_parent().add_child(flare)
		flare.global_position = global_position
		flare.apply_central_impulse((get_global_mouse_position()-global_position)*4.6)
		flare.angular_velocity = randf() * 30 - 30
		num_flares -= 1
		
	if event.is_action_pressed("click") and has_flashlight:
		flashlight_on = not flashlight_on
		
func on_battery_picked(c):
	charge = min(1, charge+c)

func on_flare_picked(n):
	num_flares += n

func _on_body_entered(body):
	if dead: return
	if body.is_in_group("ghosts"):
		dead = true
		get_node("/root/Main").set_text("[shake rate=5 level=10][color=red]YOU DIED[/color][/shake]")
		%DeathIcon.visible = true
		$SFXDeath.play()
		await get_tree().create_timer(4).timeout
		get_node("/root/Main").load_level()
	elif body.is_in_group("doors"):
		var s: AudioStreamPlayer2D = body.get_parent().get_node("Sound")
		if not s.playing:
			s.play()
		
