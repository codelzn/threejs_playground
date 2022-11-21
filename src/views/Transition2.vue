<template>
  <ul class="nav">
    <li v-for="i in 5" @mouseenter="enter(i)" @mouseleave="leave(i)" @mouseover="over(i)">{{ `${i}${i}${i}` }}</li>
  </ul>
  <div class="wrap" ref="wrap">
    <div v-for="i in 5" :class="`n n${i - 1}`" ref="divs">
      <img :src="`/transition2/${i}.jpg`" width="60">
    </div>
  </div>
  <div id="block" ref="block"></div>
  <div id="container" ref="webgl"></div>
</template>
<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import * as THREE from "three";
import gsap from "gsap";
import GUI from "lil-gui";
import vertexShader from "../assets/shaders/transition2/vertex.glsl";
import fragmentShader from "../assets/shaders/transition2/fragment.glsl";
const block = ref<HTMLDivElement>(null!)
const divs = ref<HTMLDivElement[]>([])
const wrap = ref<HTMLDivElement>(null!)
const webgl = ref<HTMLDivElement>(null!)
let main: Transition | null = null
let scroll: Scroll | null = null
let attractMode = false
const enter = (i: number) => {
  if (scroll) {
    scroll.attractMode = true
    const rots = main!.groups.map((g) => g.rotation)
    gsap.to(rots, {
      duration: 0.3,
      ease: "power4.out",
      x: 0,
      y: 0,
      z: 0,
    })
  }
}
const leave = (i: number) => {
  if(scroll) {
    scroll.attractMode = false
    const rots = main!.groups.map((g) => g.rotation)
    gsap.to(rots, {
      duration: 0.3,
      ease: "power4.out",
      x: -0.3,
      y: -0.5,
      z: -0.1,
    })
  }
}
const over = (i: number) => {
  scroll && (scroll.attractTo = i-1)
}
class Transition {
  private dom: HTMLDivElement
  private scene: THREE.Scene = new THREE.Scene()
  private sizes: { width: number; height: number }
  private renderer: THREE.WebGLRenderer = new THREE.WebGLRenderer({
    antialias: true,
  })
  private camera: THREE.PerspectiveCamera = new THREE.PerspectiveCamera(
    70,
    window.innerWidth / window.innerHeight,
    0.001,
    1000
  )
  private clock: THREE.Clock = new THREE.Clock()
  private isPlaying: boolean = true
  private material: THREE.ShaderMaterial = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    transparent: true,
    uniforms: {
      uTime: { value: 0 },
      distanceFromCenter: { value: 0 },
      texture1: { value: null }
    },
  })
  private materials: THREE.ShaderMaterial[] = []
  private loaderManager: THREE.LoadingManager = new THREE.LoadingManager()
  private textureLoader: THREE.TextureLoader = new THREE.TextureLoader(this.loaderManager)
  private textures: THREE.Texture[] = []
  public meshes: THREE.Mesh<THREE.PlaneGeometry, THREE.ShaderMaterial>[] = []
  public groups: THREE.Group[] = []
  constructor(dom: HTMLDivElement) {
    this.dom = dom
    this.sizes = { width: this.dom.offsetWidth, height: this.dom.offsetHeight }
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    this.renderer.setSize(this.sizes.width, this.sizes.height)
    this.renderer.setClearColor(0xeeeeee, 1)
    this.renderer.physicallyCorrectLights = true
    this.renderer.outputEncoding = THREE.sRGBEncoding
    this.dom.appendChild(this.renderer.domElement)
    this.camera.position.set(0, 0, 2)
    for (let i = 0;i < 5;i++) {
      this.textures.push(this.textureLoader.load(`/transition2/${i + 1}.jpg`))
    }
    this.loaderManager.onLoad = () => {
      this.init()
    }
  }
  private init() {
    this.resize()
    this.render()
    this.setResize()
    this.handleImages()
  }
  private handleImages() {
    let images = document.querySelectorAll('img')
    images.forEach((im, i) => {
      const mat = this.material!.clone()
      this.materials.push(mat)
      const group = new THREE.Group()
      mat.uniforms.texture1.value = this.textures[i]
      mat.uniforms.texture1.value.needsUpdate = true
      const geo = new THREE.PlaneGeometry(1.5, 1, 20, 20)
      const mesh = new THREE.Mesh(geo, mat)
      group.add(mesh)
      this.groups.push(group)
      this.scene.add(group)
      this.meshes.push(mesh)
      mesh.position.y = i * 1.2
      group.rotation.y = -0.5
      group.rotation.x = -0.3
      group.rotation.z = -0.1
    })
  }
  private resize() {
    this.sizes.width = this.dom.offsetWidth
    this.sizes.height = this.dom.offsetHeight
    this.renderer.setSize(this.sizes.width, this.sizes.height)
    this.camera.aspect = this.sizes.width / this.sizes.height
    this.camera.updateProjectionMatrix()
  }
  private setResize() {
    window.addEventListener('resize', this.resize.bind(this))
  }
  private render() {
    this.renderer.render(this.scene, this.camera)
    this.materials.forEach(m => m.uniforms.uTime.value = this.clock.getElapsedTime())
    window.requestAnimationFrame(this.render.bind(this))
  }
}
class Scroll {
  private elems: HTMLDivElement[]
  private wrap: HTMLDivElement
  private objs: { dist: number }[] = Array(5).fill({ dist: 0 })
  private speed: number = 0
  private position: number = 0
  private rounded: number = 0
  public attractMode: boolean = false
  public attractTo: number = 1
  public constructor(elems: HTMLDivElement[], wrap: HTMLDivElement) {
    this.elems = [...elems]
    this.wrap = wrap
    this.init()
  }
  private init() {
    window.addEventListener('wheel', e => {
      this.speed = e.deltaY * 0.0003
    })
    this.raf()
  }
  private raf() {
    this.position += this.speed
    this.speed *= 0.8
    this.objs.forEach((o, i) => {
      o.dist = Math.min(Math.abs(this.position - i), 1)
      o.dist = 1 - o.dist ** 2
      this.elems[i].style.transform = `scale(${1 + 0.4 * o.dist})`
      let scale = 1 + 0.1 * o.dist
      if (main?.meshes.length === 5) {
        main.meshes[i].position.y = i * 1.2 - this.position * 1.2
        main.meshes[i].scale.set(scale, scale, scale)
        main.meshes[i].material.uniforms.distanceFromCenter.value = o.dist
      }
    })
    this.rounded = Math.round(this.position)
    let diff = this.rounded - this.position
    if (this.attractMode) {
      this.position += -(this.position - this.attractTo) * 0.02
    } else {
      this.position += Math.sign(diff) * Math.pow(Math.abs(diff), 0.7) * 0.035
      // this.block.style.transform = `translate(0, ${this.position * 100 + 50}px)`
      this.wrap.style.transform = `translate(0, ${-this.position * 100 + 50}px)`
    }

    window.requestAnimationFrame(this.raf.bind(this))
  }
}
onMounted(async () => {
  main = new Transition(webgl.value)
  scroll = new Scroll(divs.value, wrap.value)
})
onUnmounted(() => {
})
</script>
<style scoped lang="scss">
#block {
  height: 100px;
  width: 100px;
  background-color: red;
  position: absolute;
  z-index: 100;
}

.n {
  position: absolute;
  top: 100px;
  width: 200px;
  height: 10px;
  background-color: #000;
}

.n1 {
  top: 200px;
}

.n2 {
  top: 300px;
}

.n3 {
  top: 400px;
}

.n4 {
  top: 500px;
}

#container {
  width: 100vw;
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  z-index: -1;
  pointer-events: none;
}

.nav {
  position: fixed;
  top: 0;
  right: 0;
  z-index: 100;
  border: 1px solid #000;
  width: 200px;
  list-style: none;
  margin: 0;
  padding: 0;
}
</style>