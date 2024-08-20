shader_type spatial;

uniform float cells = 12.0; // how many cells in checkerboard pattern
uniform float angle: hint_range(0, 1.57079632679) = 0.0; // repeats every PI / 2
uniform float rough_factor: hint_range(0, 5) = 3; // repeats every PI / 2
uniform sampler2D noise;

vec3 get_noise(vec2 position) {
    return texture(noise, position).xyz;
}

void vertex() { // rotate UVs by angle
	UV *= mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}

void fragment() { // assign color by even/odd checkerboard pattern
	bool cell = mod(floor(UV.x * cells) + floor(UV.y * cells), 2.0) == 0.0;
	ALBEDO = vec3(cell ? 1.0 : 0.0) - 0.1 * get_noise(UV).y;
	ROUGHNESS = get_noise(UV).y * rough_factor;
	NORMAL = (cell ? 0.1 : 0.0) + 0.2 * get_noise(UV);
}