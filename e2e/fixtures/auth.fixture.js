/**
 * Authenticated fixture.
 *
 * Usage: run `npm run test:e2e:setup` once to create storageState.json,
 * then every spec that needs an authenticated session uses this fixture
 * instead of filling the login form on every test.
 *
 * storageState.json is .gitignore'd — it contains session cookies/tokens.
 */
const { test: base } = require('@playwright/test');
const path = require('path');

const STORAGE_STATE = path.join(__dirname, 'storageState.json');

exports.test = base.extend({
  /**
   * A Playwright page context pre-loaded with a saved authentication state.
   * Falls back to a guest page if storageState.json doesn't exist yet.
   */
  authenticatedPage: async ({ browser }, use) => {
    let context;
    try {
      context = await browser.newContext({ storageState: STORAGE_STATE });
    } catch {
      // storageState.json not generated yet — run `npm run test:e2e:setup` first.
      context = await browser.newContext();
    }
    const page = await context.newPage();
    await use(page);
    await context.close();
  },
});

exports.expect = base.expect;
