const menubar = require('menubar');

const mb = menubar({
  width: 300,
  height: 200,
  preloadWindow: true
});

mb.on('ready', () => {
  console.log('app is ready');
});
