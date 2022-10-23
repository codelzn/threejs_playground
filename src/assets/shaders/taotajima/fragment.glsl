uniform sampler2D uTexture0;
uniform sampler2D uTexture1;
uniform float uProgress;
uniform float uTime;
// 加速度
uniform vec2 uAccel;

varying vec2 vUv;
varying vec2 vUv1;

//https://github.com/yuichiroharai/glsl-y-repeat/blob/master/mirrored.glsl
vec2 mirrored(vec2 v) {
  vec2 m = mod(v, 2.);
  return mix(m, 2.0 - m, step(1.0, m));
}

float tri(float p) {
  return mix(p, 1.0 - p, step(0.5, p)) * 2.;
}

void main() {
  vec2 uv = vUv;

  // fractは小数点以下を返す
  float pct = fract(uProgress);
  // 切り替える時の波紋
  float delayValue = pct * 7. - uv.y * 2. + uv.x - 2.;
  // clampは最小値と最大値を指定して値を制限する
  delayValue = clamp(delayValue, 0., 1.);

  vec2 translateValue = pct + delayValue * uAccel;
  vec2 translateValue1 = vec2(-0.5, 1.) * translateValue;
  vec2 translateValue2 = vec2(-0.5, 1.) * (translateValue - 1. - uAccel);

  vec2 w = sin(sin(uTime) * vec2(0., 0.3) + uv.yx * vec2(0., 4.)) * vec2(0., .5);
  vec2 xy = w * (tri(pct) * .5 + tri(delayValue) * .5);

  vec2 uv0 = vUv1 + translateValue1 + xy;
  vec2 uv1 = vUv1 + translateValue2 + xy;

  vec3 color0 = texture2D(uTexture0, mirrored(uv0)).rgb;
  vec3 color1 = texture2D(uTexture1, mirrored(uv1)).rgb;

  vec3 color = mix(color0, color1, delayValue);
  gl_FragColor = vec4(color, 1.);
}