varying vec2 vUv;
varying vec2 vUv1;

uniform float uFixAspect;

void main() {

  vUv = uv;
  // アスペクト補正（cover）
  vUv1 = uv - 0.5;
  vUv1.y *= uFixAspect;
  vUv1 += 0.5;

  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectionPosition = projectionMatrix * viewPosition;
  gl_Position = projectionPosition;
}