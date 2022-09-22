precision lowp float;
attribute float aScale;
attribute float imgIndex;
attribute vec3 color;
varying float vImgIndex;
varying vec2 vUv;
uniform float uTime;
varying vec3 vColor;

void main() {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  // 获取顶点角度
  float angle = atan(modelPosition.x, modelPosition.z);
  // 获取顶点到中心的距离
  float distanceToCenter = length(modelPosition.xz);
  // 根据顶点到中心的距离设置旋转偏移度数
  float angleOffset = 1.0 / distanceToCenter * uTime;
  // 目前旋转的度数
  angle += angleOffset;
  // 旋转
  modelPosition.x = cos(angle) * distanceToCenter;
  modelPosition.z = sin(angle) * distanceToCenter;
  vec4 viewPosition = viewMatrix * modelPosition;

  gl_Position = projectionMatrix * viewPosition;
  // 根据viewPosition的z值计算出缩放比例
  gl_PointSize = aScale * 100.0 / -viewPosition.z;
  vUv = uv;
  vImgIndex = imgIndex;
  vColor = color;
}