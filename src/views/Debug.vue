<template>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import * as THREE from 'three'
import Base3D from '../libs/Base3D';
const webgl = ref<HTMLCanvasElement>(null!);
let container: Main | null = null
class Main extends Base3D {
  constructor(canvas: HTMLCanvasElement) {
    super(canvas);
    const helper = new THREE.AxesHelper(5);
    this.scene.add(helper);
    this.init();
  }
  private init() {
    const geometry = new THREE.PlaneBufferGeometry(1, 1, 64, 64);
    const material = new THREE.MeshBasicMaterial({ color: 0x00ff00, side: THREE.DoubleSide });
    const cube = new THREE.Mesh(geometry, material);
    material.onBeforeCompile = (shader, renderer) => {
      // shader.vertexShader.replace()
    }
    this.scene.add(cube);
    window.addEventListener('resize', this._setResize.bind(this));
    this._render();
  }
  private _render() {
    this.renderer.render(this.scene, this.camera);
    this.controls.update();
    requestAnimationFrame(this._render.bind(this));
  }
  public destroy() {
  }
}
onMounted(() => {
  container = new Main(webgl.value);
})
onUnmounted(() => {
  container?.destroy();
})
</script>