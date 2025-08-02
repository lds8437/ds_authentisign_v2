import { createElement } from '@lwc/engine-dom';
import AuthentiSignMappingLayout from 'c/authentiSignMappingLayout';

console.log('Resolved @lwc/engine-dom:', require.resolve('@lwc/engine-dom'));

describe('c-authenti-sign-mapping-layout', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it('renders without errors', () => {
    const element = createElement('c-authenti-sign-mapping-layout', {
      is: AuthentiSignMappingLayout,
    });
    document.body.appendChild(element);
    expect(element).toBeTruthy();
    expect(element.shadowRoot).toBeTruthy();
  });
});