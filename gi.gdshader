shader_type canvas_item;
render_mode blend_disabled;

// uniforms
uniform float u_rays_per_pixel = 64;
uniform sampler2D u_scene_emissive_data;
uniform sampler2D u_scene_colour_data;
uniform sampler2D u_last_frame_data;
uniform sampler2D u_noise_data;
uniform bool u_bounce = true;
uniform bool u_denoise = true;
uniform float u_emission_multi = 2.0;
uniform float u_dir_light_multi = 50.0;
uniform float u_dir_light_thin = 10.0;
uniform float u_emission_range = 500.0;
uniform float u_emission_dropoff = 2.0;
uniform float u_bounciness = 0.8;
uniform int u_max_raymarch_steps = 32;

// ================================================================================
// get emission/colour data at this location from the last frame. this allows 'infinite'
// bounces as sufaces that were lit in the last frame will now act as emissive surfaces.
// we need to sample a 3x3 grid around the hit pixel because the surface itself won't have
// emissive data (since it is rendered black, generally), sampling around it will find the
// closest emissive pixel though, which we can consider the surface's value.
void get_last_frame_data(vec2 uv, vec2 pix, out float last_emission, out vec3 last_colour)
{
	last_emission = 0.0;
	for(int x = -1; x <= 1; x++)
	{
		for(int y = -1; y <= 1; y++)
		{
			if (x != 0 && y != 0) {
				continue;
			}
			vec4 pixel = texture(u_last_frame_data, uv + pix * vec2(float(x), float(y)));
			if(pixel.a > last_emission)
			{
				last_emission = pixel.a;
				last_colour = pixel.rgb;
			}
		}
	}
}

void fragment() 
{
	vec2 uv = UV;
	float epsilon = min(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y) / 2.0;

	vec3 col = vec3(0.0);
	float emis = 0.0;

	// get a random angle by sampling the noise texture and offsetting it by time (so we don't always sample
	// the same noise).
	vec2 time = vec2(TIME*10.1, -TIME*10.3);
	float rand = texture(u_noise_data, fract((uv + time) * 0.3)).r;
	float rand02pi = rand * 2.0 * PI; // noise sample
	float golden_angle = PI * 0.7639320225;
	float sdf = texture_sdf(screen_uv_to_sdf(uv));

	for(float i = 0.0; i < u_rays_per_pixel; i++)
	{
		vec2 hit_pos;

		// get our ray dir by taking the random angle and adding golden_angle * ray number.
		float cur_angle = rand02pi + golden_angle * i;
		vec2 rand_direction = vec2(cos(cur_angle), sin(cur_angle));

//		if (i >= u_rays_per_pixel) {
//			rand_direction = normalize(vec2(0.5, 0.5) - UV); // TODO randomness
//		}


		bool hit = false;// = raymarch(uv, rand_direction, hit_pos, hit_data, ray_dist);
		vec2 origin = screen_uv_to_sdf(uv);
		vec2 ray = rand_direction;
		float ray_dist = 0.0;
		bool inside = false;
		
//		sample_point = origin + ray * ray_dist;
//		step_dist = texture_sdf(sample_point);
		if (sdf < 0.0 && texture(u_scene_emissive_data, UV).r < epsilon) {
			inside = true;
			for(int i = 0; i < u_max_raymarch_steps/3; i++)
			{
				vec2 sample_point = origin + ray * ray_dist;
				float step_dist = texture_sdf(sample_point);

				// consider a hit if distance to surface is < epsilon (half pixel).
				if(step_dist > epsilon*5.0)
				{
					break;
				}
				step_dist -= 2.0;
				// if we didn't find a hit, step forward by the distance found in distance texture (min 1px).
				// since this distance is the distance to nearest surface, it guarantees we won't 'overstep'
				// and go past a surface. worst case is we are parallel and close to the surface, so we can't step
				// far but also won't reach the surface. this is where we have to make a trade-off in u_max_raymarch_steps.
				//step_dist = max(step_dist, min(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y));
				ray_dist += abs(step_dist);
			}
		}
		
		for(int i = 0; i < u_max_raymarch_steps; i++)
		{
			vec2 sample_point = origin + ray * ray_dist;
			float step_dist = texture_sdf(sample_point);

			// consider a hit if distance to surface is < epsilon (half pixel).
			if(step_dist < epsilon)
			{
				hit_pos = sdf_to_screen_uv(sample_point);
	  			hit = true;
				break;
			}
			// if we didn't find a hit, step forward by the distance found in distance texture (min 1px).
			// since this distance is the distance to nearest surface, it guarantees we won't 'overstep'
			// and go past a surface. worst case is we are parallel and close to the surface, so we can't step
			// far but also won't reach the surface. this is where we have to make a trade-off in u_max_raymarch_steps.
			//step_dist = max(step_dist, min(SCREEN_PIXEL_SIZE.x, SCREEN_PIXEL_SIZE.y));
			ray_dist += step_dist;
		}

		float mat_emissive;
		vec3 mat_colour;
		//get_material(hit_pos, hit_data, mat_emissive, mat_colour);
		//void get_material(vec2 uv, float hit_data, out float emissive, out vec3 colour)
		vec2 mat_uv = hit_pos;

		// if distance to nearest surface at this location is < epsilon (half pixel), we can
		// consider to be hitting that surface.
		float directional_similarity = 1.0;
		if(hit)
		{
			// read the surface data from emissive/colour maps. 
			vec4 emissive_data = texture(u_scene_emissive_data, mat_uv);
			vec4 colour_data = texture(u_scene_colour_data, mat_uv);
			mat_emissive = emissive_data.r * u_emission_multi;
			if (emissive_data.g > 0.01 || emissive_data.b > 0.01) {
				vec2 light_dir = normalize(vec2(emissive_data.g * 2.0 - 1.0, emissive_data.b * 2.0 - 1.0));
				directional_similarity = max(dot(-light_dir, ray), 0.0);
				float thin = pow(directional_similarity, u_dir_light_thin);
				colour_data = mix(vec4(1.0), colour_data, 0.1) * thin;
				mat_emissive *= thin * u_dir_light_multi;
			}
			mat_colour = colour_data.rgb;
		}
		// otherwise the raymarch reached max steps before finding a surface, so nothing is
		// contributed to the pixel brightness/colour.
		else
		{
			mat_emissive = 0.0;
			mat_colour = vec3(0.0);
		}

		float last_emission = 0.0;
		vec3 last_colour = vec3(0.0);
		if(u_bounce)
		{
			// we don't want emissive surfaces themselves to bounce light (we could, but it would probably blow
			// out the scene).
			// this is so light doesn't bounce off the surface it was emitted from. ??
			if(mat_emissive < epsilon && ray_dist > 1.0)
			{
				get_last_frame_data(hit_pos, SCREEN_PIXEL_SIZE*5.0, last_emission, last_colour);
				last_emission *= u_bounciness;
				last_emission *= directional_similarity;
			}
		}

		// calculate total emissive/colour values from direct and bounced (last frame) lighting.
		float emission = mat_emissive + last_emission;
		float r = u_emission_range;
		float drop = u_emission_dropoff;
		// attenuation calculation - very tweakable to get the correct sort of light range/dropoff.
		float att = pow(max(1.0 - (ray_dist * ray_dist) / (r * r), 0.0), u_emission_dropoff);
		//if (inside) emission /= 2.0;
		if (!inside) 
		emis += emission * att;
		col += (mat_emissive + last_emission) * (mat_colour + last_colour) * att;
	}

	// right now, emis and col store the sum of contribution of all rays to this pixel, we need
	// to normalise it.
	emis *= (1.0 / u_rays_per_pixel);
	col *= (1.0 / u_rays_per_pixel);

	if(u_denoise)
	{
		// rather rudimentary denoise where the previous frame is averaged with this frame to try and smooth the noise.
		// doesn't work particularly well.
		vec4 last_9x9_average = vec4(0.0);
		vec2 pix = SCREEN_PIXEL_SIZE;
		for(int x = -1; x <= 1; x++)
		{
			for(int y = -1; y <= 1; y++)
			{ 
				vec2 st = uv;
				last_9x9_average += texture(u_last_frame_data, st + pix * vec2(float(x), float(y)));
			}
		}
		last_9x9_average = last_9x9_average / 9.0;
		float integ = 2.0;
		COLOR = vec4((1.0 - (1.0 / integ)) * last_9x9_average.rgb + col * (1.0 / integ), emis);
	}
	else
	{
		// colour data in rgb and emissive in alpha. this is important because when reading in the last frame data we
		// need colour and alpha to be separate. if we combined at this stage, the bounce calculations wouldn't work
		// properly.
		//COLOR = vec4(lin_to_srgb(vec4(col, emis)), 0.9);
		COLOR = vec4(col, emis);

		//COLOR = vec4(texture_sdf(screen_uv_to_sdf(SCREEN_UV))/50.0);
		COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	}
//			COLOR = vec4(-texture_sdf(screen_uv_to_sdf(UV)) / 500.0);
//		COLOR.a = 1.0;
}