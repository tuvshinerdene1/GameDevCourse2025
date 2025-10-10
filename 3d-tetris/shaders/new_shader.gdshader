shader_type sky;

// Style: 0 = MGS1 (red), 1 = MGS2 (blue)
uniform int style = 1;

uniform vec3 mgs1_color = vec3(0.9, 0.2, 0.1);
uniform vec3 mgs2_color = vec3(0.1, 0.5, 0.85);

// Main Controls
uniform float grid_scale = 16.0; // Size of grid cells (increased for more detail)
uniform float grid_thickness = 0.005; // Finer grid lines
uniform float grid_opacity = 0.25; // How visible the grid is
uniform float scan_speed = 0.1; // Speed of the main scanning line
uniform float crt_scan_density = 400.0; // Density of the subtle background CRT scanlines

// CRT/Aesthetic Effects
uniform float pulse_speed = 1.5; // Speed of the ambient color pulse
uniform float ambient_glow = 0.03; // Base ambient glow

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Function to simulate subtle CRT horizontal scanlines
float crt_scanlines(vec2 uv, float density) {
    float y_pos = uv.y * density;
    // Square wave-like function for distinct dark lines
    return mix(0.9, 1.0, step(0.5, fract(y_pos)));
}

void sky() {
    vec3 dir = normalize(EYEDIR);
    vec2 uv = vec2(atan(dir.x, dir.z) / (2.0 * PI) + 0.5, acos(dir.y) / PI);

    vec3 holo_color = (style == 0) ? mgs1_color : mgs2_color;

    // Start with pure black void
    vec3 color = vec3(0.0);

    // === VIBRANCY PULSE (Key for MGS aesthetic) ===
    // This creates the "breathing" glow effect
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5; // 0.0 to 1.0
    float dynamic_glow = ambient_glow + pulse * 0.02; // A subtle boost

    // Base glow
    color += holo_color * dynamic_glow;

    // === CRT SCANLINES AND NOISE ===
    float crt_mult = crt_scanlines(uv, crt_scan_density);

    // Subtle, high-frequency noise/static (simulating poor signal)
    float static_noise = hash(floor(uv * 500.0) + floor(TIME * 5.0));
    crt_mult *= mix(1.0, 0.95, step(0.98, static_noise)); // Small random dimming

    // Apply CRT dimming to the base color
    color *= crt_mult;

    // === GRID LINES (the main visual element) ===
    vec2 grid_uv = uv * grid_scale;
    vec2 grid_frac = fract(grid_uv);

    // Calculate the distance to the nearest grid line (both axes)
    float dx = abs(grid_frac.x - 0.5);
    float dy = abs(grid_frac.y - 0.5);

    // Create thin lines using a smoothstep or max of the two distances
    float line_value = max(smoothstep(0.5 - grid_thickness, 0.5 + grid_thickness, dx),
                           smoothstep(0.5 - grid_thickness, 0.5 + grid_thickness, dy));

    // Invert the line_value to get the grid line itself
    float grid_line = 1.0 - line_value;

    // Fade grid at top/bottom for perspective/depth
    float depth_fade = smoothstep(0.0, 0.4, uv.y) * smoothstep(1.0, 0.6, uv.y);
    grid_line *= depth_fade;

    // Apply grid with color and dynamic glow based on the pulse
    color += holo_color * grid_line * grid_opacity * (1.0 + pulse * 0.3);

    // === MAIN SCAN LINE (Like a radar sweep or screen refresh) ===
    float scan_y = fract(TIME * scan_speed);
    float scan_distance = abs(uv.y - scan_y);

    // Use a soft, exponential falloff for a glowing line
    float scan_line = exp(-scan_distance * 50.0);

    // Boost the color for the scan line
    color += holo_color * scan_line * 0.5;

    // === SUBTLE VIGNETTE (for focus) ===
    vec2 center = (uv - 0.5) * 2.0;
    float vignette = 1.0 - dot(center, center) * 0.4;
    color *= vignette;

    // Output
    COLOR = color;
}