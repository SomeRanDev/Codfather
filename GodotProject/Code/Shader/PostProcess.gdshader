//shader_type spatial;
//render_mode unshaded, world_vertex_coords;
//
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;
//
//uniform float effectOpacity;
//
//varying vec3 pos;
//
//void vertex() {
	//POSITION = vec4(VERTEX.xy, 1.0, 1.0);
	//pos = VERTEX;
//}
//
//void fragment() {
	//
	//vec4 sceneColor = texture(SCREEN_TEXTURE, SCREEN_UV);
	//float sceneRed = sceneColor.r;
	//
	//float px = 0.5/VIEWPORT_SIZE.x;
	//float py = 0.5/VIEWPORT_SIZE.y;
//
	//float diff = 15.0;
	//float d = floor(sceneRed * diff) / diff;
	//float du = floor(texture(SCREEN_TEXTURE, SCREEN_UV+vec2(0.0, py)).r * diff) / diff;
	//float dd = floor(texture(SCREEN_TEXTURE, SCREEN_UV+vec2(0.0, -py)).r * diff) / diff;
	//float dr = floor(texture(SCREEN_TEXTURE, SCREEN_UV+vec2(px, 0.0)).r * diff) / diff;
	//float dl = floor(texture(SCREEN_TEXTURE, SCREEN_UV+vec2(-px, 0.0)).r * diff) / diff;
//
	//float ratio = (
		//abs(abs(d)-abs(du)) +
		//abs(abs(d)-abs(dd)) +
		//abs(abs(d)-abs(dl)) +
		//abs(abs(d)-abs(dr))
	//);
//
	////ALPHA *= 400.0;
	////ALPHA *= 100.0;
//
	//if(ratio > 0.01 && effectOpacity == 1.0) {
		//ALBEDO = vec3(0.0, 0.0, 0.0);
	//} else {
		//vec2 size = VIEWPORT_SIZE / 4.0;
		//float x = floor(SCREEN_UV.x * size.x) / size.x;
		//float y = floor(SCREEN_UV.y * size.y) / size.y;
		//vec3 result = texture(SCREEN_TEXTURE, vec2(x, y)).rgb;
		//if(ratio > 0.01) {
			//ALBEDO = mix(result, vec3(0.0, 0.0, 0.0), effectOpacity);
		//} else {
			//const float rgb_shift = 0.005;
			//float result2 = texture(SCREEN_TEXTURE, vec2(x + rgb_shift, y)).r;
			//float result3 = texture(SCREEN_TEXTURE, vec2(x - rgb_shift, y)).b;
			//ALBEDO = vec3(result2, result.g, result3);
		//}
	//}
	//ALPHA = 1.0;
//
	////.rgb;
	////ALPHA = 0.0;
//}

shader_type spatial;

render_mode unshaded, fog_disabled;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

uniform sampler2D fdfds: hint_screen_texture;

uniform vec2 resolution = vec2(320.0, 180.0);

uniform float scan_line_amount :hint_range(0.0, 1.0) = 1.0;
uniform float warp_amount :hint_range(0.0, 5.0) = 0.1;
uniform float noise_amount :hint_range(0.0, 0.3) = 0.03;
uniform float interference_amount :hint_range(0.0, 1.0) = 0.2;
uniform float grille_amount :hint_range(0.0, 1.0) = 0.1;
uniform float grille_size :hint_range(1.0, 5.0) = 1.0;
uniform float vignette_amount :hint_range(0.0, 2.0) = 0.6;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float aberation_amount :hint_range(0.0, 1.0) = 0.5;
uniform float roll_line_amount :hint_range(0.0, 1.0) = 0.3;
uniform float roll_speed :hint_range(-8.0, 8.0) = 1.0;
uniform float scan_line_strength :hint_range(-12.0, -1.0) = -8.0;
uniform float pixel_strength :hint_range(-4.0, 0.0) = -2.0;

float random(vec2 uv){
    return fract(cos(uv.x * 83.4827 + uv.y * 92.2842) * 43758.5453123);
}

vec3 fetch_pixel(vec2 uv, vec2 off, sampler2D screen_texture){
	vec2 pos = floor(uv * resolution + off) / resolution + vec2(0.5) / resolution;

	float noise = 0.0;
	if(noise_amount > 0.0){
		noise = random(pos + fract(TIME)) * noise_amount;
	}

	if(max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5){
		return vec3(0.0, 0.0, 0.0);
	}

	vec3 clr = texture(screen_texture, pos).rgb + noise;
	return clr;
}

// Distance in emulated pixels to nearest texel.
vec2 Dist(vec2 pos){ 
	pos = pos * resolution;
	return - ((pos - floor(pos)) - vec2(0.5));
}
    
// 1D Gaussian.
float Gaus(float pos, float scale){ return exp2(scale * pos * pos); }

// 3-tap Gaussian filter along horz line.
vec3 Horz3(vec2 pos, float off, sampler2D screen_texture){
	vec3 b = fetch_pixel(pos, vec2(-1.0, off), screen_texture);
	vec3 c = fetch_pixel(pos, vec2( 0.0, off), screen_texture);
	vec3 d = fetch_pixel(pos, vec2( 1.0, off), screen_texture);
	float dst = Dist(pos).x;
	
	// Convert distance to weight.
	float scale = pixel_strength;
	float wb = Gaus(dst - 1.0, scale);
	float wc = Gaus(dst + 0.0, scale);
	float wd = Gaus(dst + 1.0, scale);
	
	// Return filtered sample.
	return (b * wb + c * wc + d * wd) / (wb + wc + wd);
}

// Return scanline weight.
float Scan(vec2 pos, float off){
	float dst = Dist(pos).y;
	
	return Gaus(dst + off, scan_line_strength);
}

// Allow nearest three lines to effect pixel.
vec3 Tri(vec2 pos, sampler2D screen_texture){
	vec3 clr = fetch_pixel(pos, vec2(0.0), screen_texture);
	if(scan_line_amount > 0.0){
		vec3 a = Horz3(pos,-1.0, screen_texture);
		vec3 b = Horz3(pos, 0.0, screen_texture);
		vec3 c = Horz3(pos, 1.0, screen_texture);

		float wa = Scan(pos,-1.0);
		float wb = Scan(pos, 0.0);
		float wc = Scan(pos, 1.0);

		vec3 scanlines = a * wa + b * wb + c * wc;
		clr = mix(clr, scanlines, scan_line_amount);
	}
	return clr;
}

// Takes in the UV and warps the edges, creating the spherized effect
vec2 warp(vec2 uv){
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;
	
	vec2 warped = uv + delta * delta_offset;
	return (warped - 0.5) / mix(1.0,1.2,warp_amount/5.0) + 0.5;
}

float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_amount);
}

float floating_mod(float a, float b){
	return a - b * floor(a/b);
}

vec3 grille(vec2 uv){
	float unit = PI / 3.0;
	float scale = 2.0*unit/grille_size;
	float r = smoothstep(0.5, 0.8, cos(uv.x*scale - unit));
	float g = smoothstep(0.5, 0.8, cos(uv.x*scale + unit));
	float b = smoothstep(0.5, 0.8, cos(uv.x*scale + 3.0*unit));
	return mix(vec3(1.0), vec3(r,g,b), grille_amount);
}

float roll_line(vec2 uv){
	float x = uv.y * 3.0 - TIME * roll_speed;
	float f = cos(x) * cos(x * 2.35 + 1.1) * cos(x * 4.45 + 2.3);
	float roll_line = smoothstep(0.5, 0.9, f);
	return roll_line * roll_line_amount;
}

void fragment() {
	vec2 pix = SCREEN_UV * VIEWPORT_SIZE;
	vec2 pos = warp(SCREEN_UV);
	
	float line = 0.0;
	if(roll_line_amount > 0.0){
		line = roll_line(pos);
	}

	vec2 sq_pix = floor(pos * resolution) / resolution + vec2(0.5) / resolution;
	if(interference_amount + roll_line_amount > 0.0){
		float interference = random(sq_pix.yy + fract(TIME));
		pos.x += (interference * (interference_amount + line * 6.0)) / resolution.x;
	}

	vec3 clr = Tri(pos, fdfds);
	if(aberation_amount > 0.0){
		float chromatic = aberation_amount + line * 2.0;
		vec2 chromatic_x = vec2(chromatic*2.0,0.0) / resolution.x;
		vec2 chromatic_y = vec2(0.0, chromatic) / resolution.y;
		float r = Tri(pos - chromatic_x, fdfds).r;
		float g = Tri(pos + chromatic_y, fdfds).g;
		float b = Tri(pos + chromatic_x, fdfds).b;
		clr = vec3(r,g,b);
	}
	
	if(grille_amount > 0.0)clr *= grille(pix);
	clr *= 1.0 + scan_line_amount * 0.6 + line * 3.0 + grille_amount * 2.0;
	if(vignette_amount > 0.0)clr *= vignette(pos);
	
	ALBEDO = clr;
	//ALPHA = 1.0;
	//COLOR.a = 1.0;
}
