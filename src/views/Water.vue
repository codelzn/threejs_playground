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
  // 噪音频率
  uNoiseFrequency: number;
  // 噪音高度
  uNoiseScale: number;
  // 横纵比
  uXzScale: number;
  // 低处的颜色
  uLowColor: string;
  // 高处的颜色
  uHighColor: string;
  // 水流的X轴速度
  uXspeed: number;
  // 水流的Z轴速度
  uZspeed: number;
  // 噪声波纹速度
  uNoiseSpeed: number;
  // 透明度
  uOpacity: number;
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
      uWareFrequency: 14,
      uScale: 0.03,
      uXzScale: 1.5,
      uNoiseFrequency: 10,
      uNoiseScale: 1.5,
      uLowColor: "#ff0000",
      uHighColor: "#ffff00",
      uXspeed: 1,
      uZspeed: 1,
      uNoiseSpeed: 1,
      uOpacity: 1,
    };
  }
  public init() {
    this._setMesh();
    this._setGui();
    this._setResize();
    this._animate();
  }

  private _setMesh() {
    this.planeGeometry = new THREE.PlaneBufferGeometry(1, 1, 1024, 1024);
    this.planeMaterial = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      side: THREE.DoubleSide,
      transparent: true,
      uniforms: {
        uWareFrequency: { value: this.params.uWareFrequency },
        uScale: { value: this.params.uScale },
        uTime: { value: 0 },
        uXzScale: { value: this.params.uXzScale },
        uNoiseFrequency: { value: this.params.uNoiseFrequency },
        uNoiseScale: { value: this.params.uNoiseScale },
        uLowColor: { value: new THREE.Color(this.params.uLowColor) },
        uHighColor: { value: new THREE.Color(this.params.uHighColor) },
        uXspeed: { value: this.params.uXspeed },
        uZspeed: { value: this.params.uZspeed },
        uNoiseSpeed: { value: this.params.uNoiseSpeed },
        uOpacity: { value: this.params.uOpacity },
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
    this.gui.add(this.params, "uScale", 0, 1, 0.001).onChange(() => {
      this.planeMaterial!.uniforms.uScale.value = this.params.uScale;
    });
    this.gui.add(this.params, "uNoiseFrequency", 1, 100, 0.1).onChange(() => {
      this.planeMaterial!.uniforms.uNoiseFrequency.value = this.params.uNoiseFrequency;
    });
    this.gui.add(this.params, "uNoiseScale", 0, 5, 0.001).onChange(() => {
      this.planeMaterial!.uniforms.uNoiseScale.value = this.params.uNoiseScale;
    });
    this.gui.add(this.params, "uXzScale", 0, 5, 0.01).onChange(() => {
      this.planeMaterial!.uniforms.uXzScale.value = this.params.uXzScale;
    });
    this.gui.addColor(this.params, "uLowColor").onChange(() => {
      this.planeMaterial!.uniforms.uLowColor.value = new THREE.Color(
        this.params.uLowColor
      );
    });
    this.gui.addColor(this.params, "uHighColor").onChange(() => {
      this.planeMaterial!.uniforms.uHighColor.value = new THREE.Color(
        this.params.uHighColor
      );
    });
    this.gui.add(this.params, "uXspeed", 0, 10, 0.01).onChange(() => {
      this.planeMaterial!.uniforms.uXspeed.value = this.params.uXspeed;
    });
    this.gui.add(this.params, "uZspeed", 0, 10, 0.01).onChange(() => {
      this.planeMaterial!.uniforms.uZspeed.value = this.params.uZspeed;
    });
    this.gui.add(this.params, "uNoiseSpeed", 0, 5, 0.01).onChange(() => {
      this.planeMaterial!.uniforms.uNoiseSpeed.value = this.params.uNoiseSpeed;
    });
    this.gui.add(this.params, "uOpacity", 0, 1, 0.01).onChange(() => {
      this.planeMaterial!.uniforms.uOpacity.value = this.params.uOpacity;
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
