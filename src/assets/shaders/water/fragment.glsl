varying vec2 vUv;
varying float vElevation;
void main() {
  float a = (vElevation + 1.0) / 2.0;
  gl_FragColor = vec4(vUv.x * a, vUv.y * a, 0.0, 1.0);
}