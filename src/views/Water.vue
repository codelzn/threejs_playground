<template>
  <canvas ref="webgl"></canvas>
</template>
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import Base3D from "../libs/Base3D";
const webgl = ref<HTMLCanvasElement>(null!);
</script>
