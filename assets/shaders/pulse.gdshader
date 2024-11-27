shader_type canvas_item;

uniform bool enabled = false; // Control to enable or disable the pulse
uniform float pulse_speed : hint_range(0.1, 10.0) = 6.0; // Speed of the pulse
uniform float pulse_width : hint_range(0.0, 1.0) = 0.2; // Width of the pulse band
uniform float pulse_intensity : hint_range(0.0, 1.0) = 1.0; // Intensity of the pulse

void fragment() {
    // Get the base texture color
    vec4 tex_color = texture(TEXTURE, UV);

    if (enabled) {
        // Calculate the distance from the center
        vec2 center = vec2(0.5, 0.5); // Center of the texture
        float dist = distance(UV, center);

        // Calculate the pulse effect
        float pulse = sin(TIME * pulse_speed - dist * (1.0 / pulse_width)) * 0.5 + 0.5;

        // Modulate the pulse with intensity
        float mod_pulse = mix(1.0, 1.0 + pulse_intensity, pulse);

        // Apply the pulse to the texture
        COLOR = tex_color * vec4(mod_pulse, mod_pulse, mod_pulse, 1.0);
    } else {
        // Render the texture without any pulse effect
        COLOR = tex_color;
    }
}
