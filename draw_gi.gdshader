shader_type canvas_item;
render_mode skip_vertex_transform;

uniform sampler2D u_texture_to_draw;
uniform bool u_sRGB = true;

vec3 lin_to_srgb(vec3 color)
{
    vec3 x = color * 12.92;
    vec3 y = 1.055 * pow(clamp(color,0.,1.),vec3(0.4166667)) - 0.055;
    vec3 clr = color;
    clr.r = (color.r < 0.0031308) ? x.r : y.r;
    clr.g = (color.g < 0.0031308) ? x.g : y.g;
    clr.b = (color.b < 0.0031308) ? x.b : y.b;
    return clr;
}

void fragment() 
{
	vec4 sample = texture(u_texture_to_draw, UV);// * 0.8 + vec2(0.1));
	if(u_sRGB)
		COLOR = vec4(lin_to_srgb(sample.xyz), 1.0);
	else
		COLOR = vec4(sample.xyz, 0.9);
	COLOR = mix(COLOR, COLOR*2.0*texture(SCREEN_TEXTURE, SCREEN_UV), 1.0);
}