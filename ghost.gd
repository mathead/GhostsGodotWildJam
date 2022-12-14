extends CharacterBody2D

@onready var player = get_node("../Player")

func _ready():
	%Agent.connect("velocity_computed", velocity_computed)

func _physics_process(delta):
	var light = get_node("/root/Main").light_at(self)
	var speed = 400
	if light > 0.02:
		var player_dir = global_position.direction_to(player.global_position)
		# TODO: Find a dark spot
		%Agent.target_location = global_position - global_position.direction_to(player.global_position)*500
		velocity += -player_dir * delta * 1000 * light
		$Icon.modulate = Color.RED
		speed *= 2
	else:
		%Agent.target_location = player.global_position
		$Icon.modulate = Color.WHITE
	%Agent.set_velocity(velocity*0.95 + global_position.direction_to(%Agent.get_next_location())*delta*speed)
#	position += global_position.direction_to(%Agent.get_next_location())

func velocity_computed(vel):
	velocity = vel
	move_and_slide()
