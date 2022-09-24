attribute float aScale;
attribute vec3 aRandom;
uniform float uTime;
uniform float uSize;

void main() {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);

  modelPosition.xyz += aRandom * uTime * 10.0;

  vec4 viewPosition = viewMatrix * modelPosition;

  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;
  gl_PointSize = uSize * aScale - (uTime * 15.0);
}