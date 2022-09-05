<template>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import * as THREE from 'three'
import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader'
import { GLTFLoader, GLTF } from 'three/examples/jsm/loaders/GLTFLoader'
import { onMounted, onUnmounted, ref } from 'vue';
import Base3D from '../libs/Base3D';
import vertexShader from '../assets/shaders/lantern/vertex.glsl'
import fragmentShader from '../assets/shaders/lantern/fragment.glsl'
const webgl = ref<HTMLCanvasElement>(null!)
let controler: Lantern | null = null
class Lantern extends Base3D {
  private rgbeLoader: RGBELoader
  private gltfLoader: GLTFLoader
  private gltf?: GLTF
  private material?: THREE.ShaderMaterial
  private vert: string;
  private frag: string;
  constructor(canvas: HTMLCanvasElement, vert: string, frag: string) {
    super(canvas);
    this.vert = vert;
    this.frag = frag;
    this.renderer.outputEncoding = THREE.sRGBEncoding;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 0.5;
    this.rgbeLoader = new RGBELoader();
    this.gltfLoader = new GLTFLoader(this.loaderManager);
    this.rgbeLoader.loadAsync('/hdr/sky01.hdr').then(texture => {
      texture.mapping = THREE.EquirectangularReflectionMapping;
      this.scene.background = texture;
      this.scene.environment = texture;
    })
    this.gltfLoader.load('/model/lantern.glb', gltf => {
      this.gltf = gltf;
    })
  }

  public init() {
    this.loaderManager.onLoad = () => {
      this._setMesh();
      this._setResize();
      this._animate();
    }
  }

  private _setMesh() {
    this.material = new THREE.ShaderMaterial({
      vertexShader: this.vert,
      fragmentShader: this.frag,
      side: THREE.DoubleSide,
      transparent: true,
    })
    const lantern = this.gltf!.scene.children[1] as THREE.Mesh;
    lantern.material = this.material;
    this.scene.add(this.gltf!.scene);
  }

  private _animate() {
    requestAnimationFrame(this._animate.bind(this));
    this.renderer.render(this.scene, this.camera);
    this.controls.update();
  }

  public destory() {
    this.renderer.dispose();
  }
}
onMounted(() => {
  controler = new Lantern(webgl.value, vertexShader, fragmentShader);
  controler.init();
});
onUnmounted(() => {
  controler?.destory();
})
</script>