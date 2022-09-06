<template>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import * as THREE from "three";
import GUI from "lil-gui";
import { ref, onMounted, onUnmounted } from "vue";
import Base3D from "../libs/Base3D";
import vertexShader from "../assets/shaders/water/vertex.glsl";
import fragmentShader from "../assets/shaders/water/fragment.glsl";
const webgl = ref<HTMLCanvasElement>(null!);
let controller: Water | null = null;
type Params = {
  // 波浪的频率
  uWareFrequency: number;
  // 高低
  uScale: number;
  // 自定义
  [key: string]: any;
};
class Water extends Base3D {
  private plane?: THREE.Mesh;
  private planeGeometry?: THREE.PlaneBufferGeometry;
  private planeMaterial?: THREE.ShaderMaterial;
  private params: Params;
  private gui: GUI;
  constructor(canvas: HTMLCanvasElement) {
    super(canvas);
    this.gui = new GUI();
    this.camera.position.set(1, 1, 1);
    this.params = {
      uWareFrequency: 20,
      uScale: 0.1,
    };
  }
  public init() {
    this._setMesh();
    this._setGui();
    this._setResize();
    this._animate();
  }

  private _setMesh() {
    this.planeGeometry = new THREE.PlaneBufferGeometry(1, 1, 512, 512);
    this.planeMaterial = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      side: THREE.DoubleSide,
      transparent: true,
      uniforms: {
        uWareFrequency: { value: this.params.uWareFrequency },
        uScale: { value: this.params.uScale },
        uTime: { value: 0 },
      },
    });
    this.plane = new THREE.Mesh(this.planeGeometry, this.planeMaterial);
    this.plane.rotation.x = -Math.PI / 2;
    this.scene.add(this.plane);
  }

  private _setGui() {
    this.gui.add(this.params, "uWareFrequency", 1, 100, 0.1).onChange(() => {
      this.planeMaterial!.uniforms.uWareFrequency.value = this.params.uWareFrequency;
    });
    this.gui.add(this.params, "uScale", 0, 1, 0.01).onChange(() => {
      this.planeMaterial!.uniforms.uScale.value = this.params.uScale;
    });
  }

  private _animate() {
    requestAnimationFrame(this._animate.bind(this));
    this.planeMaterial!.uniforms.uTime.value = this.clock.getElapsedTime();
    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }

  public destory() {
    this.renderer.dispose();
    this.renderer.forceContextLoss();
    this.renderer.domElement.remove();
    this.renderer = null!;
    this.scene = null!;
    this.camera = null!;
    this.controls = null!;
    this.plane = null!;
    this.planeGeometry = null!;
    this.planeMaterial = null!;
  }
}
onMounted(() => {
  controller = new Water(webgl.value);
  controller.init();
});
onUnmounted(() => {
  controller?.destory();
});
</script>
