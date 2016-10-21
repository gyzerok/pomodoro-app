const expect = require('chai').expect;

describe('pomodoro-app', () => {
  it('should load', () => {
    const title = browser.url('/').getTitle();
    expect(title).to.equal('Pomodoro App');
  });
});
