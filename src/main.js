const menubar = require('menubar');

const rootDir = __dirname;

const mb = menubar({
  width: 300,
  height: 200,
  preloadWindow: true
});

mb.on('ready', () => {
  console.log('app is ready');
});

//mb.on('after-create-window', () => mb.window.openDevTools());
