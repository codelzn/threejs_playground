<template>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import * as THREE from 'three';
import { onMounted, ref } from 'vue';
import vertexShader from '../utils/shader/vertex.glsl';
import fragmentShader from '../utils/shader/fragment.glsl';
const webgl = ref<HTMLCanvasElement>(null!)

class Sketch {
  scene: THREE.Scene;
  camera: THREE.PerspectiveCamera;
  renderer: THREE.WebGLRenderer;
  constructor() {
    this.scene = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(
      75,
      window.innerWidth / window.innerHeight,
      0.1,
      1000
    );
    this.renderer = new THREE.WebGLRenderer({
      canvas: webgl.value!,
    });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.camera.position.z = 5;
    this.init();
  }
  public init() {
    const geometry = new THREE.BoxGeometry(1, 1, 1);
    const material = new THREE.ShaderMaterial({
      transparent: true,
      vertexShader,
      fragmentShader,
    })
    const mesh = new THREE.Mesh(geometry, material);
    this.scene.add(mesh);
  }

  animate() {
    requestAnimationFrame(this.animate.bind(this));
    this.renderer.render(this.scene, this.camera);
  }
}
onMounted(() => {
  const sketch = new Sketch();
  sketch.animate();
});
</script>