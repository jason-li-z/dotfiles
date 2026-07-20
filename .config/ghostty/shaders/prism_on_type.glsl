// Prism / glass refraction on type — replaces shake_on_type.glsl.
// Chain this LAST in your shader list.
//
// On each keystroke, a circular ripple expands outward from the cursor.
// Pixels inside the ripple band are displaced radially, as if the screen
// were glass flexing under a tap. The RGB channels are displaced by
// slightly different amounts (dispersion), so the ripple edge splits
// into a prism-like color fringe instead of a flat horizontal shift.

// --- ripple tuning ---
const float RIPPLE_DURATION = 0.35;  // seconds the ripple lives
const float RIPPLE_SPEED    = 0.0;   // ring expansion speed (uv units/sec)
const float RIPPLE_FREQ     = 3.0;  // wave frequency inside the band
const float RIPPLE_WIDTH    = 0.05;  // thickness of the active ring band

// --- refraction / prism tuning ---
const float REFRACT_STRENGTH = 0.015; // how hard pixels bend; the "glass depth"
const float DISPERSION       = 0.9;  // 0 = no color split, higher = wider prism fringe

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;

    float t = iTime - iTimeCursorChange;

    if (t < 0.0 || t >= RIPPLE_DURATION) {
        fragColor = texture(iChannel0, uv);
        return;
    }

    // Cursor center in 0..1 uv space (Ghostty gives top-left + size in pixels,
    // fragCoord origin is bottom-left, hence y - h/2)
    vec2 cursorUV = vec2(
        iCurrentCursor.x + iCurrentCursor.z * 0.5,
        iCurrentCursor.y - iCurrentCursor.w * 0.5
    ) / iResolution.xy;

    // Aspect-correct so the ripple is a circle, not an ellipse
    vec2 aspect = vec2(iResolution.x / iResolution.y, 1.0);
    vec2 p = (uv - cursorUV) * aspect;
    float dist = length(p);
    vec2 dir = dist > 1e-5 ? p / dist : vec2(0.0);

    // Envelope: quadratic decay over the ripple lifetime
    float decay = 1.0 - (t / RIPPLE_DURATION);
    decay = decay * decay;

    // Expanding ring: displacement is strongest in a gaussian band around
    // the current ring radius, oscillating like a surface wave
    float ringRadius = t * RIPPLE_SPEED;
    float band = exp(-pow((dist - ringRadius) / RIPPLE_WIDTH, 2.0));
    float wave = sin((dist - ringRadius) * RIPPLE_FREQ) * band * decay;

    // Radial refraction offset (undo aspect for sampling)
    vec2 offset = (dir / aspect) * wave * REFRACT_STRENGTH;

    // Prism dispersion: each channel refracts a different amount,
    // like wavelengths bending differently through glass
    vec3 col;
    col.r = texture(iChannel0, uv + offset * (1.0 - DISPERSION)).r;
    col.g = texture(iChannel0, uv + offset).g;
    col.b = texture(iChannel0, uv + offset * (1.0 + DISPERSION)).b;

    fragColor = vec4(col, 1.0);
}
