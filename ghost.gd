extends RigidBody2D

@onready var player = get_node("../Player")
@export var recalculate_rate = 0.2

func _ready():
	%Agent.connect("velocity_computed", velocity_computed)
	$GhostSFX.pitch_scale = randf_range (0.8,1.2)
	$GhostSFX.play()

func _physics_process(delta):
	var light = get_node("/root/Main").light_at(self)
	var speed = 300
	if light > 0.15:
		var player_dir = global_position.direction_to(player.global_position)
		# TODO: Find a dark spot
		%Agent.target_location = global_position - global_position.direction_to(player.global_position)*500
#		velocity += -player_dir * delta * 1000 * light
		apply_central_impulse(-player_dir * delta * 500 * light)
		$Icon.modulate = Color.BLACK
		speed *= 2
		
		
	else:
		if randf() < recalculate_rate:
			%Agent.target_location = player.global_position
		$Icon.modulate = Color.BLACK

#	apply_central_impulse(global_position.direction_to(%Agent.get_next_location())*delta*speed)
	%Agent.set_velocity(global_position.direction_to(%Agent.get_next_location())*delta*speed)
#	position += global_position.direction_to(%Agent.get_next_location())

func velocity_computed(vel):
	apply_central_impulse(vel)
