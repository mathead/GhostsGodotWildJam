extends Node2D

var region_scene = preload("res://nav_region.tscn")

func _ready():
	var size = 64
	var pos = Vector2(size/2.0,size/2.0)
	while pos.y < $Marker2D.position.y - size/2.0:
		while pos.x < $Marker2D.position.x - size/2.0:
			var r = region_scene.instantiate()
			get_parent().add_child.call_deferred(r)
			r.global_position = global_position + pos
			pos.x += size
		pos.x = size/2.0
		pos.y += size
