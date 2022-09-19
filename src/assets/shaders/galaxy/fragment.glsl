precision lowp float;
uniform sampler2D uTexture;
varying vec2 vUv;

void main() {
  // 设置渐变圆
  // gl_PointCoord 是内置变量，表示当前片元在点上的坐标
  // float strength = distance(gl_PointCoord, vec2(0.5));
  // 设置圆形点
  // strength = step(0.5, strength);
  // strength *= 2.0;
  // strength = 1.0 - strength;
  // gl_FragColor = vec4(strength);

  // 根据纹理设置图案
  vec4 textureColor = texture2D(uTexture, gl_PointCoord);
  // gl_FragColor = vec4(textureColor.rgb, textureColor.r);

  gl_FragColor = vec4(gl_PointCoord, 1.0, textureColor.r);
}