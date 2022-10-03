uniform float uTime;
varying vec2 vUv;

void main() {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  modelPosition.z += sin((modelPosition.x + uTime) * 3.0) * 0.2;
  modelPosition.x += cos((modelPosition.z + uTime) * 3.0) * 0.2;
  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;
  vUv = uv;
}