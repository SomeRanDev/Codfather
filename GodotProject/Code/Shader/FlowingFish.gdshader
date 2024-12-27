shader_type spatial;

uniform vec3 color: source_color;

void vertex() {
	VERTEX.y += sin((TIME * 5.0) + (VERTEX.x * 2.0)) * 0.05;
}

void fragment() {
	ALBEDO = color;
	ROUGHNESS = 0.8;
}


float DistributionGGX(float cos_theta_m, float alpha) {
	float alpha2 = alpha * alpha;
	float d = 1.0 + (alpha2 - 1.0) * cos_theta_m * cos_theta_m;
	return alpha2 / (PI * d * d);
}

float GeometryGGX(float NdotL, float NdotV, float alpha) {
	return 0.5 / mix(2.0 * NdotL * NdotV, NdotL + NdotV, alpha);
}

vec3 SchlickBaseReflectivity(float metallic, float specular, vec3 albedo) {
	float dielectric = 0.04 * specular * specular;
	return mix(vec3(dielectric), albedo, vec3(metallic));
}
	
float SchlickFresnel(float u) {
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m;
}

void light() {
	// Calculate some vectors.
	vec3 lightColor = LIGHT_COLOR / PI;
	
	vec3 half = normalize(VIEW + LIGHT);
	
	float NdotL = max(dot(NORMAL, LIGHT), 0.0);
	float NdotV = max(dot(NORMAL, VIEW), 0.0);
	float NdotH = max(dot(NORMAL, half), 0.0);
	float LdotH = max(dot(LIGHT, half), 0.0);
	
	// Diffuse light (Lambert).
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * lightColor;
	
	// Specular light (Schlick-GGX).
	float ggxAlpha = ROUGHNESS;// * ROUGHNESS;
	float D = DistributionGGX(NdotH, ggxAlpha);
	float G = GeometryGGX(NdotL, NdotV, ggxAlpha);
	
	vec3 f0 = SchlickBaseReflectivity(METALLIC, SPECULAR_AMOUNT, ALBEDO);
	float LdotH5 = SchlickFresnel(LdotH);
	float f90 = clamp(50.0 * f0.g, 0.0, 1.0);
	vec3 F = f0 + (f90 - f0) * LdotH5;
	
	vec3 specularBRDF = max(NdotL * D * G * F, 0.0);
	//SPECULAR_LIGHT += specularBRDF * LIGHT_COLOR * ATTENUATION;

	if(DIFFUSE_LIGHT.x > 0.9) DIFFUSE_LIGHT.x = 0.9;
	if(DIFFUSE_LIGHT.y > 0.9) DIFFUSE_LIGHT.y = 0.9;
	if(DIFFUSE_LIGHT.z > 0.9) DIFFUSE_LIGHT.z = 0.9;
	
	if(SPECULAR_LIGHT.x > 0.5) DIFFUSE_LIGHT.x = 0.5;
	if(SPECULAR_LIGHT.y > 0.5) DIFFUSE_LIGHT.y = 0.5;
	if(SPECULAR_LIGHT.z > 0.5) DIFFUSE_LIGHT.z = 0.5;

	if(DIFFUSE_LIGHT.x < 0.1) DIFFUSE_LIGHT.x = 0.1;
	if(DIFFUSE_LIGHT.y < 0.1) DIFFUSE_LIGHT.y = 0.1;
	if(DIFFUSE_LIGHT.z < 0.1) DIFFUSE_LIGHT.z = 0.1;
}
