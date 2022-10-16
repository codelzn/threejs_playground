<template>
  <Back />
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import Back from '../components/Back.vue'
import { ref, onMounted, onUnmounted } from "vue";
import * as THREE from "three";
import GUI from "lil-gui";
import Base3D from "../libs/Base3D";
import vertexShader from "../assets/shaders/galaxy/vertex.glsl";
import fragmentShader from "../assets/shaders/galaxy/fragment.glsl";
const webgl = ref<HTMLCanvasElement>(null!);
let controller: Galaxy | null = null;

type GalaxyParams = {
  count: number;
  size: number;
  radius: number;
  branches: number;
  spin: number;
  color: string;
  outColor: string;
};
class Galaxy extends Base3D {
  private vert: string;
  private frag: string;

  private helper: THREE.AxesHelper;
  private gui?: GUI;
  private geometry: THREE.BufferGeometry | null = null;
  private material?: THREE.ShaderMaterial;
  private points: THREE.Points | null = null;
  private texture: THREE.Texture;
  private texture1: THREE.Texture;
  private texture2: THREE.Texture;

  private params: GalaxyParams;
  private animeId?: number;
  constructor(canvas: HTMLCanvasElement, vert: string, frag: string) {
    super(canvas);
    this.camera.position.set(0, 3, 3);
    this.vert = vert;
    this.frag = frag;
    this.helper = new THREE.AxesHelper(100);
    this.scene.add(this.helper);
    // this.gui = new GUI();
    this.params = {
      count: 10000,
      size: 0.1,
      radius: 5,
      branches: 4,
      spin: 0.5,
      color: "#ff6030",
      outColor: "#1b3984",
    };
    this.texture = this.textureLoader.load("/textures/particles/10.png");
    this.texture1 = this.textureLoader.load("/textures/particles/9.png");
    this.texture2 = this.textureLoader.load("textures/particles/11.png");
  }
  public init() {
    this.loaderManager.onLoad = () => {
      this._generateGalaxy();
      this._setResize();
      this._setGui();
      this._animate();
    };
  }
  private _generateGalaxy() {
    let galaxyColor = new THREE.Color(this.params.color);
    let outGalaxyColor = new THREE.Color(this.params.outColor);
    if (this.points !== null) {
      this.geometry?.dispose();
      this.material?.dispose();
      this.scene.remove(this.points);
    }
    this.geometry = new THREE.BufferGeometry();
    const positions = new Float32Array(this.params.count * 3);
    const colors = new Float32Array(this.params.count * 3);
    const scales = new Float32Array(this.params.count);
    const imgIndex = new Float32Array(this.params.count);
    [...new Array(this.params.count)].forEach((v, i) => {
      const current = i * 3;
      const branchAngel =
        (i % this.params.branches) * ((2 * Math.PI) / this.params.branches);
      const radius = Math.random() * this.params.radius;
      const randomX =
        Math.pow(Math.random() * 2 - 1, 3) * 0.5 * (this.params.radius - radius) * 0.3;
      const randomY =
        Math.pow(Math.random() * 2 - 1, 3) * 0.5 * (this.params.radius - radius) * 0.3;
      const randomZ =
        Math.pow(Math.random() * 2 - 1, 3) * 0.5 * (this.params.radius - radius) * 0.3;

      positions[current] = Math.cos(branchAngel) * radius + randomX;
      positions[current + 1] = randomY;
      positions[current + 2] = Math.sin(branchAngel) * radius + randomZ;

      const mixColor = galaxyColor.clone();
      mixColor.lerp(outGalaxyColor, radius / this.params.radius);

      colors[current] = mixColor.r;
      colors[current + 1] = mixColor.g;
      colors[current + 2] = mixColor.b;

      // 顶点大小
      scales[current] = Math.random();

      imgIndex[current] = i % 3;
    });
    this.geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3));
    this.geometry.setAttribute("color", new THREE.BufferAttribute(colors, 3));
    this.geometry.setAttribute("aScale", new THREE.BufferAttribute(scales, 1));
    this.geometry.setAttribute("imgIndex", new THREE.BufferAttribute(imgIndex, 1));
    this.material = new THREE.ShaderMaterial({
      vertexShader: this.vert,
      fragmentShader: this.frag,
      transparent: true,
      blending: THREE.AdditiveBlending,
      depthWrite: false,
      uniforms: {
        uTime: {
          value: 0,
        },
        uTexture: {
          value: this.texture,
        },
        uTexture1: {
          value: this.texture1,
        },
        uTexture2: {
          value: this.texture2,
        },
        uColor: {
          value: galaxyColor,
        },
      },
    });
    this.points = new THREE.Points(this.geometry, this.material);
    this.camera.lookAt(this.points.position);
    this.scene.add(this.points);
  }

  private _setGui() {}

  private _animate() {
    this.animeId = requestAnimationFrame(this._animate.bind(this));
    this.renderer.render(this.scene, this.camera);
    this.controls.update();
    this.material && (this.material.uniforms.uTime.value = this.clock.getElapsedTime());
  }

  public destroy() {
    cancelAnimationFrame(this.animeId!);
    this.geometry?.dispose();
    this.material?.dispose();
    this.scene.remove(this.points!);
    this.points = null;
    this.geometry = null;
    this.material = undefined;
    this.gui?.destroy();
    this.controls.dispose();
    this.renderer.dispose();
    window.removeEventListener('resize', this._setResize.bind(this))
  }
}
onMounted(() => {
  controller = new Galaxy(webgl.value, vertexShader, fragmentShader);
  controller.init();
});
onUnmounted(() => {
  controller?.destroy();
});
</script>
