varying vec2 vUv;
uniform float uTime;
uniform float distanceFromCenter;

const float PI = 3.14159265359;
void main() {
  vUv = (uv - vec2(0.5)) * (0.8 - 0.2 * distanceFromCenter) + vec2(0.5);
  vec3 pos = position;
  pos.y += sin(PI * uv.x) * 0.01;
  pos.z = sin(PI * uv.x) * 0.02;

  pos.y += sin(uTime * 0.3) * 0.02;
  vUv.y -= sin(uTime * 0.3) * 0.02;
  vec4 modelPosition = modelMatrix * vec4(pos, 1.0);
  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectionPosition = projectionMatrix * viewPosition;
  gl_Position = projectionPosition;
}