<template>
  <canvas ref="webgl"></canvas>
</template>
<script lang="ts" setup>
import * as THREE from "three";
import { Water } from "three/examples/jsm/objects/Water2";
import gsap from "gsap";
import { RGBELoader } from "three/examples/jsm/loaders/RGBELoader";
import { GLTFLoader, GLTF } from "three/examples/jsm/loaders/GLTFLoader";
import { onMounted, onUnmounted, ref } from "vue";
import Base3D from "../libs/Base3D";
import vertexShader from "../assets/shaders/lantern/vertex.glsl";
import fragmentShader from "../assets/shaders/lantern/fragment.glsl";
import startPointVert from '../assets/shaders/firework/startPointVert.glsl'
import startPointFrag from '../assets/shaders/firework/startPointFrag.glsl'
import fireworkVert from '../assets/shaders/firework/fireworkVert.glsl'
import fireworkFrag from '../assets/shaders/firework/fireworkFrag.glsl'
const webgl = ref<HTMLCanvasElement>(null!);
let controler: Lantern | null = null;
class FireWorks {
  private color: THREE.Color;
  private startGeometry: THREE.BufferGeometry;
  private startMaterial: THREE.ShaderMaterial;
  private fireworkGeometry: THREE.BufferGeometry;
  private fireworkMaterial: THREE.ShaderMaterial;
  private fireworkCount: number;
  private startPoint: THREE.Points;
  private fireworks: THREE.Points;
  private clock: THREE.Clock;
  private scene?: THREE.Scene
  private listener1: THREE.AudioListener;
  private listener2: THREE.AudioListener;
  private sound: THREE.Audio;
  private sendSound: THREE.Audio;
  private play: boolean = false;
  private sendSoundplay: boolean = false;
  constructor(color: string, to: { x: number, y: number, z: number }, from = { x: 0, y: 0, z: 0 }) {
    this.color = new THREE.Color(color);
    this.startGeometry = new THREE.BufferGeometry();
    const startPositionArray = new Float32Array(3);
    startPositionArray[0] = from.x;
    startPositionArray[1] = from.y;
    startPositionArray[2] = from.z;
    this.startGeometry.setAttribute("position", new THREE.BufferAttribute(startPositionArray, 3));
    const astepArray = new Float32Array(3);
    astepArray[0] = to.x - from.x;
    astepArray[1] = to.y - from.y;
    astepArray[2] = to.z - from.z;
    this.startGeometry.setAttribute("aStep", new THREE.BufferAttribute(astepArray, 3));
    this.startMaterial = new THREE.ShaderMaterial({
      vertexShader: startPointVert,
      fragmentShader: startPointFrag,
      transparent: true,
      blending: THREE.AdditiveBlending,
      depthWrite: false,
      uniforms: {
        uTime: { value: 0 },
        uSize: { value: 10 },
        uColor: { value: this.color },
      }
    })
    this.startPoint = new THREE.Points(this.startGeometry, this.startMaterial);
    this.clock = new THREE.Clock();

    // hanabi
    this.fireworkGeometry = new THREE.BufferGeometry();
    this.fireworkCount = 180 + Math.floor(Math.random() * 180);
    const positionFireworksArray = new Float32Array(this.fireworkCount * 3);
    const scaleFireArray = new Float32Array(this.fireworkCount);
    const directionArray = new Float32Array(this.fireworkCount * 3);
    [...new Array(this.fireworkCount)].forEach((_, i) => {
      // hanabi start position
      positionFireworksArray[i * 3 + 0] = to.x;
      positionFireworksArray[i * 3 + 1] = to.y;
      positionFireworksArray[i * 3 + 2] = to.z;
      // 初始大小
      scaleFireArray[i] = Math.random();
      // 发射的角度
      let theta = Math.random() * Math.PI * 2;
      let beta = Math.random() * Math.PI * 2;
      let r = Math.random();
      directionArray[i * 3 + 0] = r * (Math.sin(theta) + Math.sin(beta));
      directionArray[i * 3 + 1] = r * (Math.cos(theta) + Math.cos(beta));
      directionArray[i * 3 + 2] = r * (Math.sin(theta) + Math.cos(beta));
    })
    this.fireworkGeometry.setAttribute("position", new THREE.BufferAttribute(positionFireworksArray, 3));
    this.fireworkGeometry.setAttribute("aScale", new THREE.BufferAttribute(scaleFireArray, 1));
    this.fireworkGeometry.setAttribute("aRandom", new THREE.BufferAttribute(directionArray, 3));
    this.fireworkMaterial = new THREE.ShaderMaterial({
      transparent: true,
      blending: THREE.AdditiveBlending,
      depthWrite: false,
      vertexShader: fireworkVert,
      fragmentShader: fireworkFrag,
      uniforms: {
        uTime: { value: 0 },
        uSize: { value: 0 },
        uColor: { value: this.color },
      }
    })
    this.fireworks = new THREE.Points(this.fireworkGeometry, this.fireworkMaterial);
    // music
    this.listener1 = new THREE.AudioListener()
    this.listener2 = new THREE.AudioListener()
    this.sound = new THREE.Audio(this.listener1)
    this.sendSound = new THREE.Audio(this.listener2)

    const audioLoader = new THREE.AudioLoader()
    audioLoader.load(`/audio/pow${Math.floor(Math.random() * 4) + 1}.ogg`, buffer => {
      this.sound.setBuffer(buffer)
      this.sound.setLoop(false)
      this.sound.setVolume(0.5)
    })
    audioLoader.load(`/audio/send.mp3`, buffer => {
      this.sendSound.setBuffer(buffer)
      this.sendSound.setLoop(false)
      this.sendSound.setVolume(0.2)
    })

  }

  public addScene(scene: THREE.Scene, camera: THREE.PerspectiveCamera): void {
    this.scene = scene
    this.scene.add(this.startPoint)
    this.scene.add(this.fireworks)
  }

  public update(): void | string {
    const elapsedTime = this.clock.getElapsedTime();
    if (elapsedTime > 0.2 && elapsedTime < 1) {
      if(!this.sendSound.isPlaying && !this.sendSoundplay) {
        this.sendSound.play()
        this.sendSoundplay = true
      }
      this.startMaterial.uniforms.uTime.value = elapsedTime;
      this.startMaterial.uniforms.uSize.value = 10;
      this.fireworkMaterial.uniforms.uSize.value = 0;
    } else if(elapsedTime > 0.2) {
      const time = elapsedTime - 1
      this.startMaterial.uniforms.uSize.value = 0;
      this.startPoint.clear()
      this.startGeometry.dispose()
      this.startMaterial.dispose()
      if(!this.sound.isPlaying && !this.play) {
        this.sound.play()
        this.play = true
      }
      this.fireworkMaterial.uniforms.uSize.value = 20;
      this.fireworkMaterial.uniforms.uTime.value = time;
      if (time > 5) {
        this.fireworkMaterial.uniforms.uSize.value = 0;
        this.fireworks.clear()
        this.fireworkGeometry.dispose()
        this.fireworkMaterial.dispose()
        this.scene?.remove(this.startPoint, this.fireworks)
        return 'remove'
      }
    }

  }
}
class Lantern extends Base3D {
  private rgbeLoader: RGBELoader;
  private gltfLoader: GLTFLoader;
  private gltf?: GLTF;
  private house?: GLTF;
  private material?: THREE.ShaderMaterial;
  private vert: string;
  private frag: string;
  private fireworks: FireWorks[] = [];
  constructor(canvas: HTMLCanvasElement, vert: string, frag: string) {
    super(canvas);
    this.vert = vert;
    this.frag = frag;
    this.renderer.outputEncoding = THREE.sRGBEncoding;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 0.6;
    this.camera.position.set(0, 50, 50);
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
    this.gltfLoader.load("/model/newyears_min.glb", gltf => {
      this.house = gltf;
      this.scene.add(this.house.scene);
      // 创建水面
      const waterGeometry = new THREE.PlaneBufferGeometry(100, 100);
      const water = new Water(waterGeometry, {
        scale: 4,
        textureHeight: 1024,
        textureWidth: 1024
      })
      water.rotation.x = - Math.PI * 0.5
      water.position.y = 0.1;
      this.scene.add(water)
    })
  }

  public init() {
    this.loaderManager.onLoad = () => {
      this._setMesh();
      this._setResize();
      this._animate();
      window.addEventListener('click', this._fireWork.bind(this))
    };
  }

  private _setMesh() {
    this.material = new THREE.ShaderMaterial({
      vertexShader: this.vert,
      fragmentShader: this.frag,
      side: THREE.DoubleSide,
    });
    for (let i = 0;i < 150;i++) {
      const lantern = this.gltf!.scene.clone(true);
      lantern.position.set(
        (Math.random() - 0.5) * 300,
        Math.random() * 40 + 20,
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
      const lanternMesh = lantern.children[0] as THREE.Mesh;
      lanternMesh.material = this.material;
      this.scene.add(lantern);
    }
  }

  private _animate() {
    requestAnimationFrame(this._animate.bind(this));
    this.renderer.render(this.scene, this.camera);
    this.controls.update();
    this.fireworks.forEach((firework, i) => {
      const result = firework.update();
      result === 'remove' && this.fireworks.splice(i, 1)
    });
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

  private _fireWork() {
    let color = `hsl(${Math.floor(Math.random() * 360)}, 100%, 80%)`;
    let position = {
      x: (Math.random() - 0.5) * 40,
      y: 7 + Math.random() * 25,
      z: (Math.random() - 0.5) * 40,
    }
    let firework = new FireWorks(color, position);
    firework.addScene(this.scene, this.camera);
    this.fireworks.push(firework);

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