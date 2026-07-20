// Glass cursor — static refraction, no ripple.
// The cursor cell is treated as a small slab of glass sitting on the screen:
//   - text under it is refracted (bent toward the center, strongest at the edges)
//   - each color channel bends a different amount (prism dispersion)
//   - a bright rim light traces the edges (fake fresnel)
//   - a soft glow bleeds just outside the cell
//
// This is a separate overlay: your cursor.glsl trail stays untouched.
// Chain AFTER cursor.glsl and cursor_type_flash.glsl, BEFORE prism_refraction_on_type.glsl.

// --- glass tuning ---
const float REFRACT_PX   = 2.5;  // max refraction in pixels at the cell edge
const float DISPERSION   = 0.35; // 0 = clear glass, higher = wider prism fringe
const float EDGE_CURVE   = 2.0;  // how concentrated the bend is at the edges

// --- light tuning ---
const vec4  RIM_COLOR      = vec4(1.0, 0.97, 0.85, 1.0); // warm white rim
const float RIM_WIDTH      = 0.18;  // rim thickness as fraction of half-cell
const float RIM_INTENSITY  = 0.95;
const float GLOW_RADIUS_PX = 10.0;   // soft glow falloff outside the cell
const float GLOW_INTENSITY = 0.50;
const float HIGHLIGHT      = 0.1;  // faint diagonal sheen across the glass face

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    fragColor = texture(iChannel0, uv);

    // Cursor rect in pixel space (fragCoord origin bottom-left;
    // iCurrentCursor.xy is the top-left corner, zw is width/height)
    vec2 center   = vec2(iCurrentCursor.x + iCurrentCursor.z * 0.5,
                         iCurrentCursor.y - iCurrentCursor.w * 0.5);
    vec2 halfSize = iCurrentCursor.zw * 0.5;

    // Local coords: -1..1 inside the cursor cell
    vec2 local = (fragCoord - center) / halfSize;
    float inside = step(max(abs(local.x), abs(local.y)), 1.0);

    // ---- refraction (inside the glass) ----
    // Bend increases toward the edges, like light entering a slab with
    // rounded edges; the face center stays optically flat so the glyph
    // under the cursor remains readable.
    float bend = pow(length(local) / 1.41421356, EDGE_CURVE);
    vec2 offsetPx = -local * bend * REFRACT_PX;
    vec2 offset = offsetPx / iResolution.xy;

    vec3 refracted;
    refracted.r = texture(iChannel0, uv + offset * (1.0 - DISPERSION)).r;
    refracted.g = texture(iChannel0, uv + offset).g;
    refracted.b = texture(iChannel0, uv + offset * (1.0 + DISPERSION)).b;

    // ---- rim light (fake fresnel) ----
    // Grazing angles on real glass reflect more; approximate with a bright
    // band hugging the inner edge of the cell.
    float edgeDist = 1.0 - max(abs(local.x), abs(local.y));
    float rim = smoothstep(RIM_WIDTH, 0.0, edgeDist);

    // ---- diagonal sheen across the face ----
    float sheen = clamp((local.y - local.x) * 0.5 + 0.5, 0.0, 1.0) * HIGHLIGHT;

    vec3 glassColor = refracted
                    + RIM_COLOR.rgb * rim * RIM_INTENSITY
                    + RIM_COLOR.rgb * sheen;

    fragColor.rgb = mix(fragColor.rgb, glassColor, inside);

    // ---- soft glow just outside the cell ----
    vec2 d = abs(fragCoord - center) - halfSize;
    float sdfPx = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    float glow = exp(-max(sdfPx, 0.0) / GLOW_RADIUS_PX) * (1.0 - inside);
    fragColor.rgb += RIM_COLOR.rgb * glow * GLOW_INTENSITY;
}
