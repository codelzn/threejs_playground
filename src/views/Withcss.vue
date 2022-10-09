<template>
  <div id="withcss">
    <canvas ref="webgl"></canvas>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls'
import { CSS2DRenderer, CSS2DObject } from 'three/examples/jsm/renderers/CSS2DRenderer.js'
import Base3D from '../libs/Base3D';
const webgl = ref<HTMLCanvasElement>(null!)
let controler: Withcss | null = null
class Withcss extends Base3D {
  private raycaster: THREE.Raycaster
  private earth?: THREE.Mesh
  private moon?: THREE.Mesh
  private labelRenderer
  private earthLabel?: CSS2DObject
  private moonLabel?: CSS2DObject
  private japanLabel?: CSS2DObject
  constructor(canvas: HTMLCanvasElement) {
    super(canvas)
    this.camera.position.set(0, 5, -10)
    this.raycaster = new THREE.Raycaster()
    this.labelRenderer = new CSS2DRenderer()
    this.labelRenderer.setSize(window.innerWidth, window.innerHeight)
    document.querySelector('#withcss')!.appendChild(this.labelRenderer.domElement)
    this.labelRenderer.domElement.style.position = 'fixed'
    this.labelRenderer.domElement.style.top = '0px'
    this.labelRenderer.domElement.style.left = '0px'
    this.labelRenderer.domElement.style.zIndex = '10'
    this.controls = new OrbitControls(this.camera, this.labelRenderer.domElement)
    this._init()
  }
  private _init() {
    this._initLight()
    this._initMesh()
    this._initLabel()
    this._setResize()
    this._animate()
  }
  _setResize() {
    window.addEventListener('resize', () => {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
      this.labelRenderer.setSize(window.innerWidth, window.innerHeight);
    })
  }
  private _initLight() {
    const dirLight = new THREE.DirectionalLight(0xffffff);
    dirLight.position.set(0, 0, 1);
    this.scene.add(dirLight);
    const light = new THREE.AmbientLight(0xffffff, 0.5); // soft white light
    this.scene.add(light);
  }
  private _initMesh() {
    const earthGeometry = new THREE.SphereGeometry(1, 16, 16);
    const earthMaterial = new THREE.MeshPhongMaterial({
      specular: 0x333333,
      shininess: 5,
      map: this.textureLoader.load("/planets/earth_atmos_2048.jpg"),
      specularMap: this.textureLoader.load("/planets/earth_specular_2048.jpg"),
      normalMap: this.textureLoader.load("/planets/earth_normal_2048.jpg"),
      normalScale: new THREE.Vector2(0.85, 0.85),
    });

    this.earth = new THREE.Mesh(earthGeometry, earthMaterial);
    // earth.rotation.y = Math.PI;
    this.scene.add(this.earth);
    const moonGeometry = new THREE.SphereGeometry(0.27, 16, 16);
    const moonMaterial = new THREE.MeshPhongMaterial({
      shininess: 5,
      map: this.textureLoader.load("/planets/moon_1024.jpg"),
    });
    this.moon = new THREE.Mesh(moonGeometry, moonMaterial);
    this.scene.add(this.moon);
  }
  private _initLabel() {
    const earthDiv = document.createElement('div');
    earthDiv.className = 'label_withcss';
    earthDiv.innerHTML = 'Earth';
    this.earthLabel = new CSS2DObject(earthDiv);
    this.earthLabel.position.set(0, 1, 0)
    this.earth!.add(this.earthLabel)

    const moonDiv = document.createElement('div');
    moonDiv.className = 'label_withcss';
    moonDiv.innerHTML = 'Moon';
    this.moonLabel = new CSS2DObject(moonDiv);
    this.moonLabel.position.set(0, 1, 0)
    this.moon!.add(this.moonLabel)

    const japanDiv = document.createElement('div');
    japanDiv.className = 'label_withcss';
    japanDiv.innerHTML = 'Japan';
    this.japanLabel = new CSS2DObject(japanDiv);
    this.japanLabel.position.set(0, 0.5, -0.5)
    this.earth!.add(this.japanLabel)
  }
  private _animate() {
    this.labelRenderer.render(this.scene, this.camera)
    this.renderer.render(this.scene, this.camera)
    this.moon!.position.set(Math.sin(this.clock.getElapsedTime()) * 5, 0, Math.cos(this.clock.getElapsedTime()) * 5);
    const japanPosition = this.japanLabel!.position.clone()
    const labelDistance = japanPosition.distanceTo(this.camera.position)
    japanPosition.project(this.camera)
    this.raycaster.setFromCamera(japanPosition, this.camera)
    const intersects = this.raycaster.intersectObjects(this.scene.children, true)
    this.controls.update()
    this.renderer.setAnimationLoop(this._animate.bind(this))
  }
  public destory() { }
}
onMounted(() => {
  controler = new Withcss(webgl.value)
})
onUnmounted(() => {
  controler?.destory()
})
</script>
<style lang="scss">
.label_withcss {
  color: white;
}
</style>