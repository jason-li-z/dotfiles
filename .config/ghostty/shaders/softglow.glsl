const vec3[12] samples = {
  vec3(1,0,0.5),
  vec3(-1,0,0.5),
  vec3(0,1,0.5),
  vec3(0,-1,0.5),
  vec3(0.7,0.7,0.35),
  vec3(-0.7,0.7,0.35),
  vec3(0.7,-0.7,0.35),
  vec3(-0.7,-0.7,0.35),
  vec3(2,0,0.15),
  vec3(-2,0,0.15),
  vec3(0,2,0.15),
  vec3(0,-2,0.15)
};

float lum(vec4 c) {
  return dot(c.rgb, vec3(0.299, 0.587, 0.114));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy;

  vec4 color = texture(iChannel0, uv);

  vec2 step = 2.0 / iResolution.xy;

  vec3 glow = vec3(0.0);

  for (int i = 0; i < 12; i++) {
    vec3 s = samples[i];

    vec4 c = texture(
      iChannel0,
      uv + s.xy * step
    );

    float brightness = smoothstep(
      0.55,
      1.0,
      lum(c)
    );

    glow += c.rgb * brightness * s.z;
  }

  color.rgb += glow * 0.06;

  fragColor = color;
}
