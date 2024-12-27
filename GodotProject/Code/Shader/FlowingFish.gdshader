shader_type spatial;

uniform vec3 color: source_color;

void vertex() {
	VERTEX.y += sin((TIME * 5.0) + (VERTEX.x * 2.0)) * 0.05;
}

void fragment() {
	ALBEDO = color;
}
