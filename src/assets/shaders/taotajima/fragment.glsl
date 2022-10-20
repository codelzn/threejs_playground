varying vec2 vUv;

uniform sampler2D uTexture0;
uniform sampler2D uTexture1;
uniform float uProgress;
void main() {
  vec4 color0 = texture2D(uTexture0, vUv);
  vec4 color1 = texture2D(uTexture1, vUv);
  gl_FragColor = mix(color0, color1, uProgress);
}