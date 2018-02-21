module.exports = {
  browser: true,
  verbose: true,
  testMatch: [
    '**/__tests__/**/*.js?(x)',
    '**/?(*.)jest.js?(x)'
  ],
  testPathIgnorePatterns: [
    '/node_modules/',
    '/vendor/',
    '/tmp/',
  ],
  testURL: 'https://sharesight.test/' // sets document.URL (required for )
};
