shader_type spatial;
 
uniform sampler2D noise;
uniform float line_height_vertical : hint_range(0.0, 1.0) = 0.025; // The width of the lines
uniform float gap_vertical : hint_range(0.0, 1.0) = .2; // Size of the gap between lines
uniform vec3 line_color : source_color = vec3(0.0, 0.0, 0.0); // Color of the lines
uniform vec3 background_color : source_color = vec3(1.0, 1.0, 0.0); // Background color (Yellow)

void vertex() {
	// Called for every vertex the material is visible on.
}

vec3 get_noise(vec2 position) {
    return texture(noise, position).xyz;
}

void fragment() {
	// Called for every pixel the material is visible on.
    vec2 uv = UV.xy * 60.0;
	
	// Calculate the line position within the vertical pattern
    float line_pos_y = mod(uv.y, gap_vertical);
    float line_pos_x = mod(uv.x, gap_vertical);
	
    if ((line_pos_x < line_height_vertical) || (line_pos_y < line_height_vertical)) {
        ALBEDO = mix(line_color, get_noise(UV), .2); // Mix line color with background color
    }
	else {
		ALBEDO = mix(background_color, get_noise(UV), .3);
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
