shader_type canvas_item;

uniform sampler2D noiseTexture;
uniform bool isSoft = false;
uniform float speed : hint_range(0.0, 1.0) = 0.1;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float threshold : hint_range(0.0, 2.0) = 1.0;
uniform float fluffiness : hint_range(0.0, 2.0) = 0.5;
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 1.0; // New alpha control

void fragment() {
    vec2 uv = UV;
    float time = TIME * speed;

    vec4 noise1 = texture(noiseTexture, fract(uv + vec2(time, 0.0)));
    vec4 noise2 = texture(noiseTexture, fract(uv + vec2(time * fluffiness, time * fluffiness)));
    vec4 combinedNoise = mix(noise1, noise2, 0.5); // Mix for a fluffy effect

    float alpha;
    if (isSoft) {
        alpha = smoothstep(threshold - 0.3, threshold + 0.3, combinedNoise.r) * alpha_multiplier;
    } else {
        alpha = (combinedNoise.r > threshold ? 1.0 : 0.0) * alpha_multiplier;
    }

    COLOR = vec4(combinedNoise.rgb * brightness, alpha);
}
