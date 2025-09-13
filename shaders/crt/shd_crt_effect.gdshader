shader_type spatial;
// render_mode unshaded, cull_disabled;

uniform sampler2D viewport_texture : source_color;

uniform float scan_line_count : hint_range(50.0, 500.0) = 200.0;
uniform float scan_speed      : hint_range(-10.0, 10.0)   = -1.0; // <— scroll; sign = direction
uniform float scan_intensity  : hint_range(0.0, 1.0)      = 0.6;  // <— how much to multiply
uniform float scan_contrast   : hint_range(0.5, 8.0)      = 2.0;  // <— sharpness of lines

uniform float warp_amount : hint_range(0.0, 0.1) = 0.03;
uniform float noise_amount : hint_range(0.0, 0.2) = 0.02;
uniform float chromatic_aberration : hint_range(0.0, 0.01) = 0.003;
uniform float emission_strength : hint_range(0.0, 2.0) = 0.8;
uniform bool flip_h = false;
uniform bool flip_v = false;

//const float TAU = 6.2831853;

vec2 warp_uv(vec2 uv) {
    vec2 center = uv - 0.5;
    float dist = dot(center, center);
    vec2 warped = uv + center * dist * warp_amount;
    return warped;
}

void fragment() {
    vec2 flipped_uv = UV;
    if (flip_h) { flipped_uv.x = 1.0 - flipped_uv.x; }
    if (flip_v) { flipped_uv.y = 1.0 - flipped_uv.y; }

    vec2 warped_uv = warp_uv(flipped_uv);

    // Sample with chromatic aberration
    vec3 color;
    color.r = texture(viewport_texture, warped_uv + vec2(chromatic_aberration, 0.0)).r;
    color.g = texture(viewport_texture, warped_uv).g;
    color.b = texture(viewport_texture, warped_uv - vec2(chromatic_aberration, 0.0)).b;

    // === Scrolling scanlines (multiplicative) ===
    // Sine stripe pattern in [0..1]
    float phase   = warped_uv.y * scan_line_count + TIME * scan_speed;
    float stripes = 0.5 + 0.5 * sin(phase * TAU);
    // Sharpen/soften the lines
    stripes = pow(stripes, scan_contrast);
    // Multiply against the text/image; blend amount via scan_intensity
    color *= mix(1.0, stripes, scan_intensity);
    // ===========================================

    // Noise
    float n = fract(sin(dot(warped_uv, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
    color += n * noise_amount;

    // Vignette
    float vignette = smoothstep(0.0, 0.5, distance(UV, vec2(0.5)));
    color *= 1.0 - (vignette * 0.5);

    // Edge glow
    float rim = 1.0 - dot(NORMAL, VIEW);
    rim = pow(rim, 3.0);
    vec3 edge_glow = vec3(0.1, 0.15, 0.1) * rim * 0.2;

    ALBEDO   = color;
    EMISSION = color * emission_strength + edge_glow;
    ALPHA    = 1.0;
}
