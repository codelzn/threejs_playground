<template>
  <h1>CodeLznのThree.js playground</h1>
  <ul>
    <li>
      <router-link to="/lantern">Lantern</router-link>
    </li>
    <li>
      <router-link to="/water">Water</router-link>
    </li>
    <li>
      <router-link to="/newwater">NewWater</router-link>
    </li>
    <li>
      <router-link to="/galaxy">Gaxaly</router-link>
    </li>
    <li>
      <router-link to="/firework">Firework</router-link>
    </li>
    <li>
      <router-link to="/withcss">Withcss</router-link>
    </li>
    <li>
      <router-link to="/sampleanime">SampleAnime</router-link>
    </li>
    <li>
      <router-link to="/taotajima">Taotajima</router-link>
    </li>
  </ul>
</template>
<style scoped lang="scss">
* {
  margin: 0;
  padding: 0;
}

h1 {
  text-align: center;
}

ul {
  display: grid;
  place-items: center;
  row-gap: 20px;
  width: 100%;
  margin: 10px auto;

  li {
    list-style: none;

    a {
      font-size: 30px;
      color: #e95950;
      font-weight: 700;
      text-decoration: none;
    }
  }
}
</style>
