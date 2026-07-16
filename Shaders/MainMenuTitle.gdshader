shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.6, 1.0, 1.0);
uniform float glow_radius : hint_range(0.0, 20.0) = 5.0;
uniform float glow_intensity : hint_range(0.0, 10.0) = 2.5;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE;
    float alpha_sum = 0.0;
    
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * glow_radius * size;
            alpha_sum += texture(TEXTURE, UV + offset).a;
        }
    }

    float blur = alpha_sum / 25.0;
    vec4 text_color = texture(TEXTURE, UV);
    
    vec4 glow = vec4(glow_color.rgb * glow_intensity, blur * glow_color.a);
    COLOR = mix(glow, text_color, text_color.a);
}
