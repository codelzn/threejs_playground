<template>
  <Back />
  <canvas ref="webgl"></canvas>
</template>
<script lang="ts" setup>
import Back from '../components/Back.vue'
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'
import gsap from 'gsap'
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import { RGBELoader } from "three/examples/jsm/loaders/RGBELoader";
import Base3D from '../libs/Base3D';
const webgl = ref<HTMLCanvasElement>(null!)
let controler: Flower | null = null
class Flower extends Base3D {
  private hdrLoader = new RGBELoader()
  private dracoLoader = new DRACOLoader()
  private gltfLoader = new GLTFLoader()
  private params = {
    value: 0
  }
  constructor(canvas: HTMLCanvasElement) {
    super(canvas)
    this.hdrLoader.load('/hdr/sky01.hdr', (texture) => {
      texture.mapping = THREE.EquirectangularReflectionMapping
      this.scene.background = texture
      this.scene.environment = texture
    })
    this.dracoLoader.setDecoderPath('/draco/gltf/')
    this.dracoLoader.setDecoderConfig({ type: "js" });
    this.dracoLoader.preload()
    this.gltfLoader.setDRACOLoader(this.dracoLoader)
    this.gltfLoader.load("/model/change/sphere1.glb", gltf1 => {
      this.scene.add(gltf1.scene)
      let sphere1 = gltf1.scene.children[0] as THREE.Mesh
      this.gltfLoader.load("/model/change/sphere2.glb", gltf2 => {
        sphere1.geometry.morphAttributes.position = []
        sphere1.geometry.morphAttributes.position.push((gltf2.scene.children[0] as THREE.Mesh).geometry.attributes.position)
        sphere1.updateMorphTargets()
        // sphere1.morphTargetInfluences && (sphere1.morphTargetInfluences[0] = 1)
        gsap.to(this.params, {
          value: 1,
          duration: 2,
          yoyo: true,
          repeat: -1,
          onUpdate: () => {
            sphere1.morphTargetInfluences && (sphere1.morphTargetInfluences[0] = this.params.value)
          }
        })
      })
    })
  }
  public init() {
    this._setResize()
    this._initRaf()
  }
  private _initRaf() {
    this.renderer.render(this.scene, this.camera)
    this.renderer.setAnimationLoop(this._initRaf.bind(this))
  }
  public destroy() {
    this.renderer.setAnimationLoop(null)
    this.renderer.dispose()
    this.controls.dispose()
  }
}
onMounted(() => {
  controler = new Flower(webgl.value)
  controler.init()
})
onUnmounted(() => {
  controler?.destroy()
})
</script>