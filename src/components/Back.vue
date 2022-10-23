<template>
  <h1 class="backBtn" @click="$router.back()">Back</h1>
</template>
<style scoped lang="scss">
.backBtn {
  position: fixed;
  z-index: 999;
  top: 0;
  left: 0;
  padding: 2px 10px;
  background-color: skyblue;
  border-radius: 10px;
  color: orangered;
}
</style>