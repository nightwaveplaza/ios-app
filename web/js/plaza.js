window['plaza'] = {
  vue: {},

  push: function(action, data) {
    if (action === 'openWindow') {
      this.vue.open(data.window);
    }

    if (action === 'closeWindow') {
      this.vue.close(data.window);
    }

    this.vue.pushData(action, data);
  }
};