/**
 * Polyfills loaded via jest.setupFiles — runs BEFORE setupFilesAfterFramework
 * (src/setupTests.js) and therefore before MSW is imported.
 *
 * MSW v2 / @mswjs/interceptors require TextEncoder and TextDecoder
 * which are not exposed globally by jest-environment-jsdom (Jest 27).
 * Node.js 18+ has them natively; we just promote them to globalThis.
 */
const { TextEncoder, TextDecoder } = require('util');

if (typeof globalThis.TextEncoder === 'undefined') {
  globalThis.TextEncoder = TextEncoder;
}

if (typeof globalThis.TextDecoder === 'undefined') {
  globalThis.TextDecoder = TextDecoder;
}
