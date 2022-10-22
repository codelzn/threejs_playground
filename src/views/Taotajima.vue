<template>
  <Back />
  <div class="debug" ref="debug"></div>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import Back from '../components/Back.vue'
import * as THREE from "three";
import GUI from 'lil-gui'
import vertexShader from "../assets/shaders/taotajima/vertex.glsl"
import fragmentShader from "../assets/shaders/taotajima/fragment.glsl"
const webgl = ref<HTMLCanvasElement>(null!);
const debug = ref<HTMLDivElement>(null!);
const imageUrls: string[] = [
  'https://webstatic.mihoyo.com/upload/static-resource/2021/11/08/02959a0f179436853c244dfc8b88e4e4_5824090375749016325.jpg',
  'https://webstatic.mihoyo.com/upload/static-resource/2021/11/08/306b7c8abc0f74c727be827788d5a75f_9123439517379119205.jpg',
  'https://webstatic.mihoyo.com/upload/static-resource/2021/11/08/55ccd259cca4f64ae81f2d113a153bae_8366165624319984079.png',
  'https://webstatic.mihoyo.com/upload/static-resource/2021/11/08/5f37fbd417ed2629ac812b04d6c978b7_8009591696062860345.jpg',
]
let container: Sketch | null = null;
class Sketch {
  private sizes: {
    width: number;
    height: number;
  };
  private debug: HTMLDivElement;
  private scene: THREE.Scene;
  private renderer: THREE.WebGLRenderer;
  private camera: THREE.OrthographicCamera;
  private imageUrls: string[];
  private LoaderManager: THREE.LoadingManager
  private textureLoader: THREE.TextureLoader;
  private textures: THREE.Texture[];
  private clock: THREE.Clock;
  private gui?: GUI;
  private planeGeometry?: THREE.PlaneGeometry;
  private planeMaterial?: THREE.ShaderMaterial;
  private plane?: THREE.Mesh;
  private uniforms: THREE.ShaderMaterialParameters["uniforms"];
  private scrollSpeed: number = 0.0;
  private scrollPosition: number = 0.0;
  private scrollMinusOffset: number = 1;
  private isDone: boolean = false;
  private animeID?: number;
  constructor(canvas: HTMLCanvasElement, imageUrls: string[] = [], debug: HTMLDivElement) {
    this.imageUrls = imageUrls;
    this.debug = debug;
    this.sizes = {
      width: window.innerWidth,
      height: window.innerHeight,
    };
    this.scene = new THREE.Scene();
    this.renderer = new THREE.WebGLRenderer({
      canvas,
      antialias: true,
    });
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, -1);
    this.clock = new THREE.Clock();
    this.LoaderManager = new THREE.LoadingManager();
    this.textureLoader = new THREE.TextureLoader(this.LoaderManager);
    this.textures = this.imageUrls.map(url =>
      this.textureLoader.load(url)
    );
    this.LoaderManager.onProgress = (url, loaded, total) =>
      document.title = `[${loaded} / ${total}]`;
    this.LoaderManager.onLoad = () => this.init()
  }

  private init() {
    this.uniforms = {
      uTime: { value: 0 },
      uFixAspect: { value: this.sizes.height / this.sizes.width },
      uProgress: { value: 0 },
      // uAccelは加速度
      uAccel: { value: new THREE.Vector2(0.5, 2.0) },
      uTexture0: { value: this.textures[0] },
      uTexture1: { value: this.textures[1] },
    }
    document.title = 'texture loaded'
    this._setPlane()
    window.addEventListener('resize', this._resize.bind(this))
    window.addEventListener('wheel', e => {
      // 垂直方向のスクロール量
      this.scrollSpeed += e.deltaY * 0.0002
    })
    this._anime()
  }

  private _setPlane() {
    this.planeGeometry = new THREE.PlaneGeometry(2, 2, 1, 1);
    this.planeMaterial = new THREE.ShaderMaterial({
      vertexShader,
      fragmentShader,
      uniforms: this.uniforms,
    });
    this.plane = new THREE.Mesh(this.planeGeometry, this.planeMaterial);
    this.scene.add(this.plane);
  }

  private set texture0(index: number) {
    this.uniforms!.uTexture0.value = this.textures[index]
  }
  private set texture1(index: number) {
    this.uniforms!.uTexture1.value = this.textures[index]
  }

  private _update() {
    this.scrollPosition += this.scrollSpeed
    // スピードを減衰させる
    this.scrollSpeed *= 0.7

    // 画像の切り替え 一番近い画像のインデックスを無目標に
    const target = Math.floor(this.scrollPosition);
    if (Math.abs(target - this.scrollPosition) < 0.001) {
      // 近すぎると固定させる
      this.scrollPosition = target
    } else {
      // 遠いときは、一番近い画像にゆっくり近づける
      this.scrollPosition += (target - this.scrollPosition) * 0.03
    }
    // 止まってるかどうかを判定
    target === this.scrollPosition ? this.isDone = true : this.isDone = true

    const size = this.textures.length
    let currentIndex = Math.floor(this.scrollPosition) % size
    let nextIndex = (currentIndex + 1) % size

    // マイナスの場合
    if (this.scrollPosition < 0) {
      currentIndex = (size * this.scrollMinusOffset - Math.abs(Math.floor(this.scrollPosition))) % size

      if (currentIndex < 0) {
        ++this.scrollMinusOffset
        currentIndex = (size * this.scrollMinusOffset - Math.abs(Math.floor(this.scrollPosition))) % size
      }

      nextIndex = (currentIndex + 1) % size
    }
    this.debug.innerHTML = `
    <ul>
    <li>currentIndex: ${currentIndex}<li>
    <li>nextIndex: ${nextIndex}</li>
    <li>scrollPosition: ${this.scrollPosition.toFixed(3)}</li>
    <li>target: ${target}</li>
    <li>isDone: ${this.isDone}</li>
    </ul>
    `
    this.planeMaterial!.uniforms.uTime.value = this.clock.getElapsedTime();
    this.planeMaterial!.uniforms.uProgress.value = this.scrollPosition;
    this.texture0 = currentIndex
    this.texture1 = nextIndex
  }

  private _anime() {
    this.animeID = window.requestAnimationFrame(this._anime.bind(this));
    this._update()
    this.isDone && this.renderer.render(this.scene, this.camera);
  }

  private _resize() {
    this.sizes.width = window.innerWidth;
    this.sizes.height = window.innerHeight;
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.uniforms!.uFixAspect.value = this.sizes.height / this.sizes.width;
    this.camera.updateProjectionMatrix();
  }

  public destroy() {
    window.removeEventListener('resize', this._resize.bind(this))
    window.removeEventListener('wheel', this._resize.bind(this))
    this.renderer.dispose()
    window.cancelAnimationFrame(this.animeID!)
  }
}
onMounted(() => {
  container = new Sketch(webgl.value, imageUrls, debug.value);
});
onUnmounted(() => {
  container?.destroy();
  container = null;
});
</script>
<style scoped lang="scss">
* {
  padding: 0;
  margin: 0;
}

canvas {
  position: fixed;
  display: block;
  top: 0;
  left: 0;
}

.debug {
  position: fixed;
  top: 0;
  right: 5px;
  z-index: 100;
  background-color: yellow;

  ul {
    list-style: none;
    display: flex;
    flex-direction: column;
  }
}
</style>