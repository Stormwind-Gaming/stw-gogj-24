shader_type canvas_item;

uniform float transition : hint_range(0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float intensity = mix(0.0, 1.0, transition); // Blend from black to white
    COLOR = vec4(vec3(intensity), tex_color.a); // Use alpha from the texture
}