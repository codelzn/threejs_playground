precision lowp float;
varying vec2 vUv;
varying vec4 vPosition;
varying vec3 gPosition;

void main () {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vPosition = modelPosition;
  gPosition = position;
  vUv = uv;
  gl_Position = projectionMatrix * viewMatrix * modelPosition;
}