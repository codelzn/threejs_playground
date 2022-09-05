precision lowp float;
varying vec2 vUv;
varying vec4 vPosition;
varying vec3 gPosition;

void main() {
  vec4 startColor = vec4(1.0, 0.0, 0.0, 1.0);
  vec4 endColor = vec4(1.0, 1.0, 0.5, 1.0);
  vec4 mixedColor = mix(startColor, endColor, gPosition.y / 2.7);

  // 判断是否是正面
  if(gl_FrontFacing) {
    gl_FragColor = vec4(mixedColor.xyz - vPosition.y / 60.0 - 0.1, 1.0);
  } else {
    gl_FragColor = mixedColor;
  }
}