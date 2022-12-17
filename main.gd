extends Node2D

var lightmap: Image
var lightning = 0.0
var lightning_emis = 0.0
var levels = [
	preload("res://level_1.tscn"),
	load("res://level_2.tscn"),
	load("res://level_3.tscn"),
	load("res://level_4.tscn"),
	load("res://level_5_flares.tscn"),
	load("res://level_pillars.tscn"),
	load("res://level_fan.tscn"),
	load("res://level_many_ghosts.tscn"),
	load("res://level_maze.tscn"),
	]
var cur_level = 2
var level_scene
var m = 1 # resolution multiplier

# Called when the node enters the scene tree for the first time.
func _ready():
	%Resolution.select(2)
	
	%GIViewport.world_2d = %MainViewport.world_2d
	%Emissive.world_2d = %MainViewport.world_2d
	%GI.material.set_shader_parameter("u_scene_colour_data", %MainViewport.get_texture())
	%GI.material.set_shader_parameter("u_scene_emissive_data", %Emissive.get_texture())
	%GI.material.set_shader_parameter("u_last_frame_data", %LastFrameBufferViewport.get_texture())
	%LastFrameBuffer.material.set_shader_parameter("u_texture_to_draw", %GIViewport.get_texture())
	%DrawGI.material.set_shader_parameter("u_texture_to_draw", %GIViewport.get_texture())
	lightmap = %GIViewport.get_texture().get_image() 
	
	# Set correct order
	RenderingServer.viewport_set_active(%MainViewport.get_viewport_rid(), false)
	RenderingServer.viewport_set_active(%MainViewport.get_viewport_rid(), true)
	RenderingServer.viewport_set_active(%Emissive.get_viewport_rid(), false)
	RenderingServer.viewport_set_active(%Emissive.get_viewport_rid(), true)
	RenderingServer.viewport_set_active(%LastFrameBufferViewport.get_viewport_rid(), false)
	RenderingServer.viewport_set_active(%LastFrameBufferViewport.get_viewport_rid(), true)
	RenderingServer.viewport_set_active(%GIViewport.get_viewport_rid(), false)
	RenderingServer.viewport_set_active(%GIViewport.get_viewport_rid(), true)
	
	load_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var s = 0.8
	#var t = get_viewport_rect().size * ((1-s) /2)
	%GIViewport.canvas_transform = %MainViewport.canvas_transform#.scaled(Vector2(s,s)).translated(t) # TODO: different resolution
	%Emissive.canvas_transform = %MainViewport.canvas_transform#.scaled(Vector2(s,s)).translated(t)
	%FPS.text = "FPS " + str(Engine.get_frames_per_second())
	lightmap = %GIViewport.get_texture().get_image() # TODO: shader that gets max
#	lightmap.generate_mipmaps()  shrink_x2

func _physics_process(delta):
	var color = Color.WHITE
	if lightning > 0:
		if randf() < 0.1:
			lightning_emis = 1.0 + randf()
		lightning -= delta
		color = Color.WHITE * lightning
	else:
		color = Color("4a6161")
		if randf() < 0.005:
			lightning_emis = 1.5 + randf()
			lightning = 0.5 + randf() * 0.3
		
	lightning_emis = lerp(lightning_emis, 0.02, 0.5)
	for window in get_tree().get_nodes_in_group("windows"):
		window.Icon.modulate = color
		window.Emis.modulate.r = lightning_emis

func light_at(node):
	var pos = node.get_global_transform_with_canvas().origin
	if not Rect2i(Vector2.ZERO, lightmap.get_size()).has_point(pos):
		return 0.01
	return lightmap.get_pixelv(pos).get_luminance()


func _on_gfx_slider_value_changed(value):
	%GI.material.set_shader_parameter("u_rays_per_pixel", value)

func _on_settings_button_toggled(button_pressed):
	%Settings.visible = button_pressed

func _on_resolution_item_selected(index):
	var b = Vector2(1280, 720)
	var r = [b/4, b/2, b][index]
#	DisplayServer.window_set_size(r)
	%GIViewport.size = r
	%Emissive.size = r
	%LastFrameBufferViewport.size = r
	%MainViewport.size = r
	get_viewport().content_scale_size = r
	m = (2**(2-index))
	%HUD.scale = Vector2.ONE / m
	%GI.material.set_shader_parameter("u_emission_range", 1000.0 / m)	
	get_tree().get_nodes_in_group("Camera")[0].zoom = Vector2(0.8, 0.8) / m
	%MarginContainer.size = %MarginContainer.size
	

func load_level():
	if level_scene:
		level_scene.free()
	level_scene = levels[cur_level].instantiate()
	%MainViewport.add_child(level_scene)
	get_tree().get_nodes_in_group("Camera")[0].zoom = Vector2(0.8, 0.8) / m

func next_level():
	cur_level += 1
	load_level()

func _on_reload_button_pressed():
	load_level()
