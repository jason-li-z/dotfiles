// Glass ruler v2 — modeled as a glass half-cylinder lying on the cursor's
// line, not a uniform magnifier. The glass-ness comes from four cues:
//   1. text BOWS: flat at the band center, bending sharply near the edges
//      (cylindrical lens profile), instead of scaling uniformly
//   2. visible prism dispersion where the bend is strongest
//   3. a specular streak running along the ruler where it catches light
//   4. top-lit shading: upper half slightly bright, lower half slightly dark
//
// Chain AFTER cursor.glsl, BEFORE glass_cursor.glsl.

// --- lens tuning ---
const float BULGE_PX   = 4.0;  // max vertical bend in pixels near the edges
const float DISPERSION = 0.6;  // per-channel bend spread (prism fringe)
const float BAND_SCALE = 1.15; // ruler height in cursor-cell heights

// --- glass shading tuning ---
const float SPEC_POS       = 0.45;  // specular streak position (-1 bottom .. 1 top)
const float SPEC_WIDTH     = 0.14;  // streak thickness
const float SPEC_INTENSITY = 0.20;  // streak brightness
const float SHADE          = 0.20;  // top-light / bottom-shadow gradient
const float EDGE_GLINT     = 0.06;  // bright caustic line at the ruler edges
const vec4  LIGHT_COLOR    = vec4(1.0, 0.97, 0.85, 1.0); // warm white

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    fragColor = texture(iChannel0, uv);

    // Current row band in pixel space (fragCoord origin bottom-left;
    // iCurrentCursor.y is the cell's top edge, w its height)
    float rowCenter = iCurrentCursor.y - iCurrentCursor.w * 0.5;
    float halfH = iCurrentCursor.w * 0.5 * BAND_SCALE;

    float local = (fragCoord.y - rowCenter) / halfH; // -1..1 inside the band
    if (abs(local) > 1.0) {
        return; // outside the ruler — untouched
    }

    // Cylindrical lens profile: displacement ~ local^3.
    // Zero slope at the center (text under the middle stays crisp and
    // unmoved) with rapidly increasing bend toward the edges — the
    // signature look of print under a glass rod.
    float bend = local * local * local; // -1..1, flat around 0
    float offsetPxG = -bend * BULGE_PX;

    // Prism dispersion: each channel bends a different amount. The fringe
    // appears exactly where the bend is strong (band edges), like real glass.
    float offR = offsetPxG * (1.0 - DISPERSION);
    float offB = offsetPxG * (1.0 + DISPERSION);

    vec3 col;
    col.r = texture(iChannel0, vec2(uv.x, (fragCoord.y + offR)      / iResolution.y)).r;
    col.g = texture(iChannel0, vec2(uv.x, (fragCoord.y + offsetPxG) / iResolution.y)).g;
    col.b = texture(iChannel0, vec2(uv.x, (fragCoord.y + offB)      / iResolution.y)).b;

    // Top-lit shading: cylinder lit from above — upper surface catches
    // light, lower surface falls into slight shadow.
    col *= 1.0 + SHADE * local;

    // Specular streak: the long bright reflection line along the rod.
    // This is the single strongest "it's glass" cue.
    float spec = exp(-pow((local - SPEC_POS) / SPEC_WIDTH, 2.0)) * SPEC_INTENSITY;

    // Edge caustics: thin bright lines where the glass meets the page.
    float edgeDistPx = (1.0 - abs(local)) * halfH;
    float glint = smoothstep(1.5, 0.0, edgeDistPx) * EDGE_GLINT;

    fragColor.rgb = col + LIGHT_COLOR.rgb * (spec + glint);
}
