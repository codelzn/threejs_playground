<template>
  <Back />
  <h5 class="tips">パソコンのみご覧いただけます</h5>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import Back from "../components/Back.vue";
import { onMounted, onUnmounted, ref } from "vue";
import * as THREE from "three";
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js';
import GUI from 'lil-gui'
import gsap from "gsap";
import { CurtainShader } from '../assets/shaders/transition1/effect1'
import { RGBAShader } from "../assets/shaders/transition1/effect2";
const webgl = ref<HTMLCanvasElement>(null!);
let gl: Transition1 | null = null;
class Transition1 {
  private sizes: { width: number; height: number } = {
    width: window.innerWidth,
    height: window.innerHeight,
  };
  private scene: THREE.Scene = new THREE.Scene();
  private camera: THREE.PerspectiveCamera = new THREE.PerspectiveCamera(
    60,
    this.sizes.width / this.sizes.height,
    1,
    3000
  );
  private renderer: THREE.WebGLRenderer = new THREE.WebGLRenderer({
    canvas: webgl.value,
    antialias: true,
  });
  private clock: THREE.Clock = new THREE.Clock();
  private gui: GUI = new GUI();
  private composer: EffectComposer = new EffectComposer(this.renderer);
  private renderPass: RenderPass = new RenderPass(this.scene, this.camera);
  private shaderPass: ShaderPass = new ShaderPass(CurtainShader);
  private shaderPass2: ShaderPass = new ShaderPass(RGBAShader);
  private loaderManager: THREE.LoadingManager = new THREE.LoadingManager();
  private textureLoader: THREE.TextureLoader = new THREE.TextureLoader(this.loaderManager);
  private textureUrls: string[] = [
    '/imgs/img01.jpg',
    '/imgs/img02.jpg',
    '/imgs/img03.jpg',
  ]
  private maskTexture: THREE.Texture = this.textureLoader.load('/imgs/mask.jpg');
  private textures: THREE.Texture[] = [];
  private geometry: THREE.PlaneGeometry = new THREE.PlaneGeometry(1920, 1080, 1, 1);;
  private groups: THREE.Group[] = [];
  private mouse: THREE.Vector2 = new THREE.Vector2();
  private mouseTarget: THREE.Vector2 = new THREE.Vector2();
  private animeId?: number;
  private time: number = 0;
  private oscilator: number = 0;
  private slideProgress: number = 0;
  private isComplete: boolean = true;
  constructor() {
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.physicallyCorrectLights = true;
    this.camera.position.set(0, 0, 900);
    this.composer.addPass(this.renderPass);
    this.composer.addPass(this.shaderPass);
    this.composer.addPass(this.shaderPass2);
    this.textureUrls.forEach((url) => {
      this.textures.push(this.textureLoader.load(url));
    });
    this.textures[this.textures.length] = this.textures[0];
    console.log(this.textures);
    this.loaderManager.onLoad = () => {
      this._init();
    };
  }

  private _init() {
    this._addObjects();
    this._resize();
    this._mouseEvent()
    this._render()
    this._setting();
    window.addEventListener("resize", this._resize.bind(this));
  }

  private _setting() {
    const settings = {
      runAnimetion: () => this._runAnimetion(),
    }
    this.gui.add(settings, 'runAnimetion')
  }

  private _runAnimetion() {
    if (!this.isComplete) {
      return;
    }
    let t1 = gsap.timeline();
    if (this.slideProgress === this.textures.length - 1) {
      this.slideProgress = 0;
      this.camera.position.set(0, 0, 900);
    }
    t1.to(this.camera.position, {
      x: "+=" + 2500,
      duration: 1.5,
      ease: 'power4.inOut',
      onStart: () => {
        this.isComplete = false;
      },
      onComplete: () => {
        this.slideProgress += 1;
        this.isComplete = true;
      }
    })

    t1.to(this.camera.position, {
      z: 700,
      duration: 1,
      ease: 'power4.inOut',
    }, 0)
    t1.to(this.camera.position, {
      z: 900,
      duration: 1,
      ease: 'power4.inOut',
    }, 1)

    t1.to(this.shaderPass.uniforms.uProgress, {
      value: 1,
      duration: 1,
      ease: 'power3.inOut',
    }, 0)

    t1.to(this.shaderPass.uniforms.uProgress, {
      value: 0,
      duration: 1,
      ease: 'power3.inOut',
    }, 1)

    t1.to(this.shaderPass2.uniforms.uProgress, {
      value: 1,
      duration: 1,
      ease: 'power3.inOut',
    }, 0)

    t1.to(this.shaderPass2.uniforms.uProgress, {
      value: 0,
      duration: 1,
      ease: 'power3.inOut',
    }, 1)

  }

  private _addObjects() {
    this.textures.forEach((t, j) => {
      let group = new THREE.Group();
      this.scene.add(group);
      this.groups.push(group);
      for (let i = 0;i < 3;i++) {
        let m = new THREE.MeshBasicMaterial({
          map: t,
        });
        if (i > 0) {
          m = new THREE.MeshBasicMaterial({
            map: t,
            alphaMap: this.maskTexture,
            transparent: true,
          });
        }
        const mesh = new THREE.Mesh(this.geometry, m);
        mesh.position.z = (i + 1) * 100
        group.add(mesh);
        group.position.x = j * 2500;
      }
    })
  }

  private _mouseEvent() {
    this.renderer.domElement.addEventListener('mousemove', (e) => {
      this.mouse.x = (e.clientX / this.sizes.width) * 2 - 1;
      this.mouse.y = (e.clientY / this.sizes.height) * 2 - 1;
    })
  }
  private _resize() {
    this.sizes.width = window.innerWidth;
    this.sizes.height = window.innerHeight;
    this.camera.aspect = this.sizes.width / this.sizes.height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(this.sizes.width, this.sizes.height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.composer.setSize(this.sizes.width, this.sizes.height);
  }
  private _render() {
    this.time = this.clock.getElapsedTime();
    this.oscilator = Math.sin(this.time * 0.1) * 0.5 + 0.5;
    this.mouseTarget.lerp(this.mouse, 0.1)
    this.groups.forEach(g => {
      g.rotation.x = - this.mouseTarget.y * 0.3;
      g.rotation.y = - this.mouseTarget.x * 0.3;
      g.children.forEach((m, i) => {
        m.position.z = (i + 1) * 100 + this.oscilator * 200;
      })
    })
    this.composer.render();
    this.animeId = window.requestAnimationFrame(this._render.bind(this));
  }
  public destroy() {
    window.removeEventListener("resize", this._resize.bind(this));
    window.cancelAnimationFrame(this.animeId!);
    this.renderer.domElement.removeEventListener('mousemove', (e) => {
      this.mouse.x = (e.clientX / this.sizes.width) * 2 - 1;
      this.mouse.y = (e.clientY / this.sizes.height) * 2 - 1;
    })
    this.renderer.dispose();
    this.gui.destroy();
  }
}
onMounted(() => {
  gl = new Transition1();
})
onUnmounted(() => {
  gl?.destroy();
  gl = null;
})
</script>
<style scoped lang="scss">
.tips {
  position: fixed;
  bottom: 0;
  left: 0;
  color: orange;
  background-color: #fff;
  pointer-events: none;
}
</style>