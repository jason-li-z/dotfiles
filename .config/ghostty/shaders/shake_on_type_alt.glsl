// Screen shake + RGB split on type — no bloom, no blur.
// Chain this LAST in your shader list.
//
// Shake: stepped/quantized offsets (snaps between random positions instead
// of gliding) with quadratic decay — sharp jolt, quick settle.
// Aberration: the R and B channels are sampled with a horizontal offset that
// rides the same decay envelope, so the split twitches only on keystrokes.

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// --- shake tuning ---
const float SHAKE_DURATION  = 0.18;    // seconds
const float SHAKE_INTENSITY = 0.00025; // max offset in UV space
const float SHAKE_RATE      = 28.0;    // jumps per second; lower = chunkier

// --- rgb split tuning ---
const float AB_INTENSITY = 3.5;  // horizontal split in pixels at full strength
const float AB_JITTER    = 0.6;  // 0 = steady split, 1 = split width jumps around too

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;

    float timeSinceShake = iTime - iTimeCursorChange;

    vec2 shakeOffset = vec2(0.0);
    float decay = 0.0;
    float t = floor(iTime * SHAKE_RATE); // shared stepped time

    if (timeSinceShake >= 0.0 && timeSinceShake < SHAKE_DURATION) {
        // Cubic decay: strong only for the first few frames, then gone
        decay = 1.0 - (timeSinceShake / SHAKE_DURATION);
        decay = decay * decay * decay;

        shakeOffset.x = (hash(t)        - 0.5) * 2.0 * SHAKE_INTENSITY * decay;
        shakeOffset.y = (hash(t + 57.0) - 0.5) * 2.0 * SHAKE_INTENSITY * decay;
    }

    uv += shakeOffset;

    // RGB split: sample R and B with opposing horizontal offsets.
    // Uses a slower (linear) decay than the shake so the color fringe
    // lingers a beat after the displacement settles — more readable.
    float abDecay = 0.0;
    if (timeSinceShake >= 0.0 && timeSinceShake < SHAKE_DURATION) {
        abDecay = 1.0 - (timeSinceShake / SHAKE_DURATION);
    }
    float jitter = mix(1.0, hash(t + 113.0), AB_JITTER);
    float split = (AB_INTENSITY / iResolution.x) * abDecay * jitter;

    vec3 col;
    col.r = texture(iChannel0, vec2(uv.x - split, uv.y)).r;
    col.g = texture(iChannel0, uv).g;
    col.b = texture(iChannel0, vec2(uv.x + split, uv.y)).b;

    fragColor = vec4(col, 1.0);
}