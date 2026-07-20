// Ghostty cursor trail shader — with intentional glow
// Based on https://gist.github.com/chardskarth/95874c54e29da6b5a36ab7b50ae2d088

float ease(float x) {
    return pow(1.0 - x, 10.0);
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Based on Inigo Quilez's 2D distance functions article:
// https://iquilezles.org/articles/distfunctions2d/
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float blend(float t)
{
    float sqr = t * t;
    return sqr / (2.0 * (sqr - t) + 1.0);
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y);
    float condition2 = step(a.x, b.x) * step(b.y, a.y);
    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

// ── Colors ──────────────────────────────────────────────────────────
const vec4 TRAIL_COLOR = vec4(0.478, 0.514, 0.486, 0.38);        // #7a837c cliff_green
const vec4 TRAIL_COLOR_ACCENT = vec4(0.655, 0.847, 0.690, 0.28); // #a7d8b0
// Glow color: brighter than the accent so the halo reads as light.
const vec3 GLOW_COLOR = vec3(0.655, 0.847, 0.690);               // #a7d8b0

// ── Tunables ────────────────────────────────────────────────────────
const float DURATION = .2;
// Glow intensity — 0.55 ≈ 2x the brightness the old buggy halo produced.
// Raise toward 1.0+ for more bloom, lower toward 0.2 for subtle.
const float GLOW_INTENSITY = 0.55;
// Glow spread — LOWER = wider halo. 30.0 is a wide soft bloom,
// 80.0 is a tight rim of light. (Units: normalized screen space.)
const float GLOW_FALLOFF = 30.0;
// Extra persistent glow around the cursor block itself (0.0 to disable).
const float CURSOR_GLOW_INTENSITY = 0.35;
const float CURSOR_GLOW_FALLOFF = 60.0;

const float DRAW_THRESHOLD = 1.5;
const bool HIDE_TRAILS_ON_THE_SAME_LINE = false;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;

    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

    vec4 newColor = vec4(fragColor);

    float progress = blend(clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0));
    float easedProgress = ease(progress);

    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float cursorSize = max(currentCursor.z, currentCursor.w);
    float trailThreshold = DRAW_THRESHOLD * cursorSize;
    float lineLength = distance(centerCC, centerCP);

    float sdfCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);

    // ── Persistent cursor glow (independent of trail/jumps) ─────────
    if (CURSOR_GLOW_INTENSITY > 0.0) {
        float cursorGlow = exp(-max(sdfCursor, 0.0) * CURSOR_GLOW_FALLOFF);
        // Additive: adds light instead of tinting, so it looks like a glow.
        fragColor.rgb += GLOW_COLOR * cursorGlow * CURSOR_GLOW_INTENSITY
                         * step(0.0, sdfCursor); // don't brighten inside the cursor
    }

    bool isFarEnough = lineLength > trailThreshold;
    bool isOnSeparateLine = HIDE_TRAILS_ON_THE_SAME_LINE ? currentCursor.y != previousCursor.y : true;
    if (isFarEnough && isOnSeparateLine) {
        float distanceToEnd = distance(vu.xy, centerCC);
        float alphaModifier = clamp(distanceToEnd / (lineLength * easedProgress), 0.0, 1.0);
        float fade = 1.0 - alphaModifier; // 1 at cursor → 0 at trail tail

        float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

        // ── Trail body (FIXED: smoothstep args in correct order) ────
        newColor = mix(newColor, TRAIL_COLOR_ACCENT, 1.0 - smoothstep(-0.01, 0.001, sdfTrail));
        newColor = mix(newColor, TRAIL_COLOR, antialising(sdfTrail));
        newColor = mix(fragColor, newColor, fade);

        // ── Intentional glow: exponential halo outside the trail ────
        float halo = exp(-max(sdfTrail, 0.0) * GLOW_FALLOFF);
        newColor.rgb += GLOW_COLOR * halo * GLOW_INTENSITY * fade;

        // Keep the cursor block itself clean
        fragColor = mix(newColor, fragColor, step(sdfCursor, 0.0));
    }
}
