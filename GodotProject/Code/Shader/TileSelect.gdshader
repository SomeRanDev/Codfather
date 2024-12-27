shader_type spatial;
render_mode cull_disabled, unshaded;

uniform sampler2D noise;

void fragment() {
	ALPHA_SCISSOR_THRESHOLD = 1.0 - UV.y;
	ALPHA = texture(noise, UV + vec2(0.0, TIME / 1.0)).r;
	ALBEDO = vec3(1.0, 1.0, 0.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
