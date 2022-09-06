<template>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import * as THREE from "three";
import gsap from "gsap";
import { RGBELoader } from "three/examples/jsm/loaders/RGBELoader";
import { GLTFLoader, GLTF } from "three/examples/jsm/loaders/GLTFLoader";
import { onMounted, onUnmounted, ref } from "vue";
import Base3D from "../libs/Base3D";
import vertexShader from "../assets/shaders/lantern/vertex.glsl";
import fragmentShader from "../assets/shaders/lantern/fragment.glsl";
const webgl = ref<HTMLCanvasElement>(null!);
let controler: Lantern | null = null;
class Lantern extends Base3D {
  private rgbeLoader: RGBELoader;
  private gltfLoader: GLTFLoader;
  private gltf?: GLTF;
  private material?: THREE.ShaderMaterial;
  private vert: string;
  private frag: string;
  constructor(canvas: HTMLCanvasElement, vert: string, frag: string) {
    super(canvas);
    this.vert = vert;
    this.frag = frag;
    this.renderer.outputEncoding = THREE.sRGBEncoding;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1;
    this.controls.autoRotate = true;
    this.controls.autoRotateSpeed = 0.3;
    this.rgbeLoader = new RGBELoader();
    this.gltfLoader = new GLTFLoader(this.loaderManager);
    this.rgbeLoader.loadAsync("/hdr/sky02.hdr").then((texture) => {
      texture.mapping = THREE.EquirectangularReflectionMapping;
      this.scene.background = texture;
      this.scene.environment = texture;
    });
    this.gltfLoader.load("/model/lantern.glb", (gltf) => {
      this.gltf = gltf;
    });
  }

  public init() {
    this.loaderManager.onLoad = () => {
      this._setMesh();
      this._setResize();
      this._animate();
    };
  }

  private _setMesh() {
    this.material = new THREE.ShaderMaterial({
      vertexShader: this.vert,
      fragmentShader: this.frag,
      side: THREE.DoubleSide,
    });
    for (let i = 0; i < 150; i++) {
      const lantern = this.gltf!.scene.clone(true);
      lantern.position.set(
        (Math.random() - 0.5) * 300,
        Math.random() * 60 + 25,
        (Math.random() - 0.5) * 300
      );
      gsap.to(lantern.rotation, {
        y: Math.PI * 2,
        duration: 10 + Math.random() * 10,
        repeat: -1,
      });
      gsap.to(lantern.position, {
        x: "+=" + Math.random(),
        y: "+=" + Math.random() * 20,
        duration: 5 + Math.random() * 15,
        repeat: -1,
        yoyo: true,
      });
      const lanternMesh = lantern.children[1] as THREE.Mesh;
      lanternMesh.material = this.material;
      this.scene.add(lantern);
    }
  }

  private _animate() {
    requestAnimationFrame(this._animate.bind(this));
    this.renderer.render(this.scene, this.camera);
    this.controls.update();
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
  controler = new Lantern(webgl.value, vertexShader, fragmentShader);
  controler.init();
});
onUnmounted(() => {
  controler?.destory();
});
</script>
