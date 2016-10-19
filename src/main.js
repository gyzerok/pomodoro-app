const menubar = require('menubar');

const mb = menubar({
  width: 300,
  height: 200,
  preloadWindow: true,
  index: 'http://localhost:3000'
});

mb.on('ready', () => {
  console.log('app is ready');
});
