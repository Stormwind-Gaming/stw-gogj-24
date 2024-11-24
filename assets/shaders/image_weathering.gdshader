shader_type canvas_item;

uniform float scratch_intensity : hint_range(0.0, 1.0) = 0.5; // Intensity of scratches
uniform float discoloration : hint_range(0.0, 1.0) = 0.3;     // Intensity of discoloration
uniform float angle : hint_range(0.0, 3.14159) = 0.5;         // Angle of scratches in radians
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.5; // Intensity of vignette
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.75;  // Radius of vignette
uniform float fade_intensity : hint_range(0.0, 1.0) = 0.3;    // Intensity of fading edges
uniform sampler2D noise_texture;                              // Noise texture for randomness

void fragment() {
    vec2 uv = UV; // UV coordinates mapped to the image

    // Rotate UVs to angle the scratches
    mat2 rotation = mat2(vec2(cos(angle), -sin(angle)),
                         vec2(sin(angle),  cos(angle)));
    vec2 rotated_uv = rotation * (uv - 0.5) + 0.5; // Center UV before rotation

    // Generate irregular scratches
    float scratch = sin(rotated_uv.y * 60.0 + sin(rotated_uv.x * 80.0)) * 0.5 + 0.5; // Adjust frequencies
    scratch *= step(0.95, fract(rotated_uv.x * 30.0 + texture(noise_texture, uv).r * 10.0)); // Randomized gaps
    scratch *= scratch_intensity; // Scale by intensity uniform

    // Base texture color
    vec4 tex_color = texture(TEXTURE, uv);

    // Discoloration effect
    vec3 sepia_tone = vec3(0.8, 0.6, 0.4); // Sepia color
    vec3 discolored = mix(tex_color.rgb, sepia_tone, discoloration); // Blend with discoloration

    // Vignette effect
    float dist = distance(uv, vec2(0.5)); // Distance from the center
    float vignette = smoothstep(vignette_radius, vignette_radius - 0.2, dist); // Smooth falloff
    vignette = mix(1.0, vignette, vignette_intensity); // Blend vignette effect with intensity

    // Fading edges
    float fade = smoothstep(0.5, 1.0, dist); // Use vignette distance for fading
    vec3 faded_edges = mix(discolored, vec3(1.0), fade * fade_intensity); // Blend with white for faded edges

    // Combine all effects
    vec3 final_color = faded_edges - vec3(scratch); // Subtract scratches from faded edges
    final_color *= vignette; // Apply vignette effect

    // Preserve alpha
    COLOR = vec4(final_color, tex_color.a);
}
