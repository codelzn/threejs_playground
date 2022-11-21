varying vec2 vUv;
uniform sampler2D texture1;
uniform float distanceFromCenter;
void main() {
  vec4 t = texture2D(texture1, vUv);
  float bw = (t.r + t.g + t.b) / 3.0;
  vec4 another = vec4(bw, bw, bw, 1.0);
  gl_FragColor = mix(another, t, distanceFromCenter);
  gl_FragColor.a = clamp(distanceFromCenter, 0.2, 1.0);
}