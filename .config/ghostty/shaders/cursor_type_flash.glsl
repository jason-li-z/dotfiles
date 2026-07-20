// Typing flash — cursorblaze recolored to warm white/yellow to match the glow tint.
// Chain this in ghostty config alongside your trail shader, BEFORE the glow shader.

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

vec2 norm(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

float ease(float x) {
    return pow(1.0 - x, 3.0);
}

// Warm white / soft yellow — tuned to sit in the same family as the bloom tint.
// Nudge the .g/.b channels down for more yellow, up for whiter.
const vec4 TYPE_COLOR        = vec4(1.0, 0.93, 0.72, 1.0); // soft yellow body
const vec4 TYPE_COLOR_ACCENT = vec4(1.0, 0.99, 0.92, 1.0); // near-white core
const float DURATION = 0.25;      // seconds
const float FLASH_OPACITY = 0.1; // 0.0 = invisible, 1.0 = full brightness

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    vec2 vu = norm(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor  = vec4(norm(iCurrentCursor.xy, 1.),  norm(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(norm(iPreviousCursor.xy, 1.), norm(iPreviousCursor.zw, 0.));

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);

    float sdfCurrentCursor = getSdfRectangle(
        vu,
        currentCursor.xy - (currentCursor.zw * offsetFactor),
        currentCursor.zw * 0.5
    );

    float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float easedProgress = ease(progress);
    float lineLength = distance(centerCC, centerCP);

    vec4 flash = mix(TYPE_COLOR_ACCENT, fragColor, 1. - smoothstep(0., sdfCurrentCursor + .002, 0.004));
    flash = mix(TYPE_COLOR, flash, 1. - smoothstep(0., sdfCurrentCursor + .002, 0.004));
    // Dim the whole effect so navigation animations read as the dominant motion
    flash = mix(fragColor, flash, FLASH_OPACITY);
    fragColor = mix(flash, fragColor, 1. - smoothstep(0., sdfCurrentCursor, easedProgress * lineLength));
}
