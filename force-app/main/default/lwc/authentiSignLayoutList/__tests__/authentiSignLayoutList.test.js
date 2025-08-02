import { createElement } from '@lwc/engine-dom';
import AuthentiSignLayoutList from 'c/authentiSignLayoutList';

console.log('Resolved @lwc/engine-dom:', require.resolve('@lwc/engine-dom'));

describe('c-authenti-sign-layout-list', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it('renders without errors', () => {
    const element = createElement('c-authenti-sign-layout-list', {
      is: AuthentiSignLayoutList,
    });
    document.body.appendChild(element);
    expect(element).toBeTruthy();
    expect(element.shadowRoot).toBeTruthy();
  });
});