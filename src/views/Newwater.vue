<template>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import * as THREE from "three";
import { Water } from "three/examples/jsm/objects/Water2";
import { RGBELoader } from "three/examples/jsm/loaders/RGBELoader";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader";
import { ref, onMounted, onUnmounted } from "vue";
import Base3D from "../libs/Base3D";
const webgl = ref<HTMLCanvasElement>(null!);
let controller: Newwater | null = null;
class Newwater extends Base3D {
  private water?: Water;
  private rgbeLoader: RGBELoader;
  private gltfLoader: GLTFLoader;
  private directionalLight: THREE.DirectionalLight;
  constructor(canvas: HTMLCanvasElement) {
    super(canvas);
    this.rgbeLoader = new RGBELoader(this.loaderManager);
    this.gltfLoader = new GLTFLoader(this.loaderManager);
    this.directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
    this.scene.add(this.directionalLight);
    this.camera.position.set(5, 5, 5);
  }
  public init() {
    this._setEnvironment();
    this._setWater();
    this._setResize();
    this._animate();
  }

  private async _setEnvironment() {
    const hdr = await this.rgbeLoader.loadAsync("/hdr/waterpetch.hdr");
    hdr.mapping = THREE.EquirectangularReflectionMapping;
    this.scene.background = hdr;
    this.scene.environment = hdr;
  }

  private async _setWater() {
    const yugang = await this.gltfLoader.loadAsync("/model/yugang.glb");
    const obj1 = yugang.scene.children[0] as THREE.Mesh<
      THREE.BufferGeometry,
      THREE.MeshStandardMaterial
    >;
    const obj2 = yugang.scene.children[1] as THREE.Mesh<
      THREE.BufferGeometry,
      THREE.MeshStandardMaterial
    >;
    obj1.material.side = THREE.DoubleSide;
    this.scene.add(obj1);
    this.water = new Water(obj2.geometry, {
      color: "#ffffff",
      scale: 1,
      flowDirection: new THREE.Vector2(1, 1),
      textureWidth: 1024,
      textureHeight: 1024,
    });
    this.scene.add(this.water);
  }

  private _animate() {
    requestAnimationFrame(this._animate.bind(this));
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
  }
}
onMounted(() => {
  controller = new Newwater(webgl.value);
  controller.init();
});
onUnmounted(() => {
  controller?.destory();
});
</script>
