extends Node2D

var lightmap: Image

# Called when the node enters the scene tree for the first time.
func _ready():
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var s = 0.8
	#var t = get_viewport_rect().size * ((1-s) /2)
	%GIViewport.canvas_transform = %MainViewport.canvas_transform#.scaled(Vector2(s,s)).translated(t) # TODO: different resolution
	%Emissive.canvas_transform = %MainViewport.canvas_transform#.scaled(Vector2(s,s)).translated(t)
	%FPS.text = str(Engine.get_frames_per_second())
	lightmap = %GIViewport.get_texture().get_image() # TODO: shader that gets max
#	lightmap.generate_mipmaps()  shrink_x2
		
func light_at(node):
	var pos = node.get_global_transform_with_canvas().origin
	if not Rect2i(Vector2.ZERO, lightmap.get_size()).has_point(pos):
		return 0.01
	return lightmap.get_pixelv(pos).get_luminance()
