shader_type spatial;
render_mode blend_mix, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D grass_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec2 grass_uv_scale = vec2(25.0, 25.0);
uniform float height_blend_zone : hint_range(0.1, 15.0) = 4.0;
uniform float grass_height_max : hint_range(0.0, 100.0) = 8.0;
uniform float snow_height_min : hint_range(0.0, 100.0) = 28.0;

uniform float slope_rock_start : hint_range(0.0, 1.0) = 0.4;
uniform float slope_rock_full : hint_range(0.0, 1.0) = 0.7;

uniform vec4 grass_color1 : source_color = vec4(0.22, 0.52, 0.14, 1.0);
uniform vec4 grass_color2 : source_color = vec4(0.30, 0.58, 0.20, 1.0);
uniform vec4 rock_color1 : source_color = vec4(0.40, 0.38, 0.33, 1.0);
uniform vec4 rock_color2 : source_color = vec4(0.50, 0.44, 0.38, 1.0);
uniform vec4 snow_color : source_color = vec4(0.90, 0.92, 0.96, 1.0);

uniform float rough_grass : hint_range(0.0, 1.0) = 0.85;
uniform float rough_rock : hint_range(0.0, 1.0) = 0.50;
uniform float rough_snow : hint_range(0.0, 1.0) = 0.30;

varying vec3 v_world_pos;
varying vec3 v_world_normal;
varying float v_height;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_world_normal = normalize((MODEL_NORMAL_MATRIX * NORMAL).xyz);
	v_height = VERTEX.y;
}

float hash2d(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise2d(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash2d(i), hash2d(i + vec2(1.0, 0.0)), f.x),
		mix(hash2d(i + vec2(0.0, 1.0)), hash2d(i + vec2(1.0, 1.0)), f.x),
		f.y
	);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	float f = 1.0;
	for (int i = 0; i < 5; i++) {
		v += a * noise2d(p * f);
		f *= 2.1;
		a *= 0.48;
	}
	return v;
}

vec4 triplanar(sampler2D tex, vec3 pos, vec3 nrm, vec2 scl) {
	vec3 b = abs(nrm);
	b = pow(b, vec3(3.5));
	b /= dot(b, vec3(1.0));
	return texture(tex, pos.zy * scl) * b.x +
	       texture(tex, pos.xz * scl) * b.y +
	       texture(tex, pos.xy * scl) * b.z;
}

void fragment() {
	float h = v_height;
	vec3 n = v_world_normal;
	float slope = 1.0 - abs(n.y);

	float grass_w = 1.0 - smoothstep(grass_height_max - height_blend_zone, grass_height_max + height_blend_zone, h);
	float snow_w = smoothstep(snow_height_min - height_blend_zone, snow_height_min + height_blend_zone, h);
	float rock_w = 1.0 - grass_w - snow_w;
	rock_w = clamp(rock_w, 0.0, 1.0);
	grass_w = clamp(grass_w, 0.0, 1.0);

	float slope_r = smoothstep(slope_rock_start, slope_rock_full, slope);
	float g = grass_w * (1.0 - slope_r);
	float r = max(rock_w, slope_r);
	float s = snow_w * (1.0 - slope * 0.6);

	float total_weight = g + r + s;
	g /= total_weight;
	r /= total_weight;
	s /= total_weight;

	vec4 grass_samp = triplanar(grass_tex, v_world_pos, n, grass_uv_scale);
	float grass_var = fbm(v_world_pos.xz * 0.25);
	vec3 grass_albedo = mix(grass_color1.rgb, grass_color2.rgb, grass_var * 0.5 + 0.5);
	grass_albedo = mix(grass_albedo, grass_albedo * grass_samp.rgb * 1.3, 0.75);

	float rock_var = fbm(v_world_pos.xz * 0.5);
	vec3 rock_albedo = mix(rock_color1.rgb, rock_color2.rgb, rock_var * 0.5 + 0.5);
	float rock_streaks = fbm(v_world_pos.xz * 0.12 + vec2(0.0, 50.0));
	rock_albedo *= 0.7 + 0.6 * rock_streaks;

	float snow_var = fbm(v_world_pos.xz * 0.35);
	vec3 snow_albedo = snow_color.rgb * (0.90 + 0.20 * snow_var);

	vec3 albedo = g * grass_albedo + r * rock_albedo + s * snow_albedo;
	float roughness = g * rough_grass + r * rough_rock + s * rough_snow;

	ALBEDO = albedo;
	ROUGHNESS = roughness;
	SPECULAR = 0.12;
}
