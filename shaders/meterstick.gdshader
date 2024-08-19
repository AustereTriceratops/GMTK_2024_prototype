shader_type spatial;

uniform float line_height_vertical : hint_range(0.0, 1.0) = 0.025; // The width of the lines
uniform float line_length : hint_range(0.0, 1.0) = 0.2; // Length of the lines
uniform float line_length_short : hint_range(0.0, 1.0) = 0.2; // Length of the lines
uniform float gap_vertical : hint_range(0.0, 1.0) = 0.07; // Size of the gap between lines
uniform vec3 line_color : source_color = vec3(0.0, 0.0, 0.0); // Color of the lines
uniform vec3 background_color : source_color = vec3(1.0, 1.0, 0.0); // Background color (Yellow)
uniform float y_scale  = 1;

void fragment() {
    // Coordinates in the UV space
    vec2 uv = UV.xy * y_scale;

  // Set the background color
    vec3 color = background_color;
	float short_line_vertical_displace = line_height_vertical + gap_vertical*.5 - line_height_vertical*.5;
	float short_line_vertical_displace_end = line_height_vertical + gap_vertical*.5 + line_height_vertical*.5;
	
	bool long_not_short = false;
    // Check if the fragment is in the right half of the screen (in normalized device coordinates)
    if (uv.x < line_length) {
		long_not_short = !long_not_short;
        // Calculate the total vertical spacing (line spacing + gap)
        float total_spacing = line_height_vertical + line_height_vertical + gap_vertical;

        // Calculate the line position within the vertical pattern
        float line_pos = mod(uv.y, total_spacing);
        
        // Determine if within a line or a gap
        bool is_within_line = line_pos <= line_height_vertical;
        bool is_within_short_line = line_pos > short_line_vertical_displace && line_pos < short_line_vertical_displace_end && uv.x < line_length_short;
        //float dist = abs(line_pos - (line_height_vertical / 2.0)) - (line_height_vertical / 2.0);

        // Determine if we are within the line area
        //float alpha = smoothstep(-0.01, 0.01, -dist);
		
        if (is_within_line || is_within_short_line) {
            color = mix(color, line_color, 1); // Mix line color with background color
        }
		
		
        //if (!is_within_gap && dist <= line_length / 2.0) {
            //color = mix(color, line_color, alpha); // Mix line color with background color
        //}
    }

    ALBEDO = color; // Set the final color output
}