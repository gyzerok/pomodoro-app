require('./style.css');

const Elm = require('./Pomodoro.elm');
const app = Elm.Pomodoro.fullscreen();

app.ports.notifyTimerFinished.subscribe(() => {
  new Notification('Pomodoro App', {
    body: 'You have completed your chilicornie and now can have some rest!'
  });
});
