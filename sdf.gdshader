shader_type canvas_item;

void fragment() {
	COLOR = vec4(vec3(texture_sdf(screen_uv_to_sdf(SCREEN_UV))/500.0), 1.0);
}
