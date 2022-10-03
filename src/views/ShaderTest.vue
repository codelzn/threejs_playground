<template>
  <canvas ref="webgl"></canvas>
</template>
<script lang="ts" setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'
import Base3D from '../libs/Base3D';
import vertexShader from '../assets/shaders/shaderTest/vertex.glsl'
import fragmentShader from '../assets/shaders/shaderTest/fragment.glsl'
const webgl = ref<HTMLCanvasElement>(null!)
let controler: ShaderTest | null = null
class ShaderTest extends Base3D {
  private geometry: THREE.SphereBufferGeometry
  private material: THREE.ShaderMaterial
  private mesh: THREE.Mesh
  constructor(canvas: HTMLCanvasElement) {
    super(canvas)
    this.camera.position.z = 2
    this.geometry = new THREE.SphereBufferGeometry(1, 1, 64, 64)
    this.material = new THREE.ShaderMaterial({
      transparent: true,
      side: THREE.DoubleSide,
      vertexShader,
      fragmentShader,
      uniforms: {
        uTime: { value: 0 }
      }
    })
    this.mesh = new THREE.Mesh(this.geometry, this.material)
    this.scene.add(this.mesh)
    this._init()
  }
  private _init() {
    window.addEventListener('resize', this._setResize)
    this._animate()
  }
  private _animate() {
    this.renderer.render(this.scene, this.camera)
    this.controls.update()
    this.material.uniforms!.uTime.value = this.clock.getElapsedTime()
    this.renderer.setAnimationLoop(this._animate.bind(this))
  }
  public destory() { }
}
onMounted(() => {
  controler = new ShaderTest(webgl.value)
})
onUnmounted(() => {
  controler?.destory()
})
</script>
<style lang="scss" scoped>

</style>