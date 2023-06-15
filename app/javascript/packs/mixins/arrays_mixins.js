import Vue from 'vue'

Vue.mixin({
  methods: {
    arrays_equal(array1, array2) {
      let a = array1.sort();
      let b = array2.sort();
      return Array.isArray(a) &&
        Array.isArray(b) &&
        a.length === b.length &&
        a.every((val, index) => val === b[index]);
    }
  }
})
