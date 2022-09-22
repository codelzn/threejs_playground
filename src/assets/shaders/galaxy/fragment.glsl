precision lowp float;
uniform sampler2D uTexture;
uniform sampler2D uTexture1;
uniform sampler2D uTexture2;
varying vec2 vUv;
varying float vImgIndex;
varying vec3 vColor;

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
  // gl_FragColor = vec4(textureColor.rgb, textureColor.r);
  vec4 textureColor;
  if(vImgIndex == 0.0) {
    textureColor = texture2D(uTexture, gl_PointCoord);
  } else if(vImgIndex == 1.0) {
    textureColor = texture2D(uTexture1, gl_PointCoord);
  } else if(vImgIndex == 2.0) {
    textureColor = texture2D(uTexture2, gl_PointCoord);
  }
  gl_FragColor = vec4(vColor, textureColor.r);
}