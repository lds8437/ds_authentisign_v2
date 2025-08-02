const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
   preset: '@lwc/jest-preset',
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '^lwc$': '<rootDir>/node_modules/lwc',
    '^@lwc/engine-dom$': '<rootDir>/node_modules/@lwc/engine-dom',
    '^@salesforce/apex': '<rootDir>/force-app/test/jest-mocks/apex',
    '^lightning/': '<rootDir>/force-app/test/jest-mocks/lightning/',
  },
  transform: {
    '^.+\\.(js|html)$': '@lwc/jest-transformer',
  },
  testPathIgnorePatterns: ['/node_modules/'],
  roots: ['<rootDir>/force-app/main/default/lwc'],
};
