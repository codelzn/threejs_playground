uniform vec3 uLowColor;
uniform vec3 uHighColor;
varying vec2 vUv;
varying float vElevation;
void main() {
  float a = (vElevation + 1.0) / 2.0;
  // 混合色
  vec3 color = mix(uLowColor, uHighColor, a);
  gl_FragColor = vec4(color, 1.0);
}