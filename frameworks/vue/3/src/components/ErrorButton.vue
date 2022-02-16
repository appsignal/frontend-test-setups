<template>
  <button @click="throwError">TEST ERROR</button>
</template>

<script lang="ts">
  import { Options, Vue } from 'vue-class-component';

  @Options({
    name: 'ErrorButton',
    methods: {
      throwError() {
        throw new Error('Vue 3 TEST ERROR')
      }
    }
  })

  export default class ErrorButton extends Vue {}
</script>
