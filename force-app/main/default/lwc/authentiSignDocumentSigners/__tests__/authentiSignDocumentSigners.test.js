import { createElement } from '@lwc/engine-dom';
import AuthentiSignDocumentSigners from 'c/authentiSignDocumentSigners';

console.log('Resolved @lwc/engine-dom:', require.resolve('@lwc/engine-dom'));

describe('c-authenti-sign-document-signers', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it('renders without errors', () => {
    const element = createElement('c-authenti-sign-document-signers', {
      is: AuthentiSignDocumentSigners,
    });
    document.body.appendChild(element);
    expect(element).toBeTruthy();
  });
});