shader_type canvas_item;

uniform vec4 water_color : source_color = vec4(0.12, 0.47, 0.71, 0.8);
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float time_scale : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    float time = TIME * time_scale;
    
    // Create wave effect
    uv.x += sin(uv.y * 10.0 + time * wave_speed) * wave_amplitude;
    uv.y += cos(uv.x * 10.0 + time * wave_speed) * wave_amplitude;
    
    // Apply water color
    COLOR = texture(TEXTURE, uv) * water_color;
}
