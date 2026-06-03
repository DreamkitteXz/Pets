/**
 * E2E — Authentication flows.
 *
 * These tests run against the real application (CRA dev server on :3000).
 * Firebase Auth is NOT mocked at the E2E level; tests use a dedicated
 * test account whose credentials come from environment variables so
 * real credentials never live in the repo.
 *
 * Required env vars (set in CI secrets or a local .env.playwright file):
 *   E2E_TEST_EMAIL    — a Firebase Auth account that exists
 *   E2E_TEST_PASSWORD — its password
 */
const { test, expect } = require('@playwright/test');
const { LoginPage } = require('../pages/LoginPage');

const TEST_EMAIL    = process.env.E2E_TEST_EMAIL    || 'test@example.com';
const TEST_PASSWORD = process.env.E2E_TEST_PASSWORD || 'password123';

test.describe('Authentication', () => {

  test.describe('Login page UI', () => {
    test('shows the login form by default', async ({ page }) => {
      const loginPage = new LoginPage(page);
      await loginPage.goto();

      await expect(loginPage.emailInput()).toBeVisible();
      await expect(loginPage.passwordInput()).toBeVisible();
      await expect(loginPage.submitButton()).toBeVisible();
    });

    test('shows the Google sign-in button', async ({ page }) => {
      const loginPage = new LoginPage(page);
      await loginPage.goto();
      await expect(loginPage.googleButton()).toBeVisible();
    });

    test('switches to sign-up mode when "Cadastre-se" is clicked', async ({ page }) => {
      const loginPage = new LoginPage(page);
      await loginPage.goto();
      await loginPage.switchToSignUp();

      await expect(loginPage.nameInput()).toBeVisible();
      await expect(loginPage.signUpButton()).toBeVisible();
    });
  });

  test.describe('Protected route redirect', () => {
    test('redirects unauthenticated user to /auth when accessing /', async ({ page }) => {
      await page.goto('/');
      await page.waitForURL('**/auth**');
      expect(page.url()).toContain('/auth');
    });

    test('redirects unauthenticated user to /auth when accessing /pets', async ({ page }) => {
      await page.goto('/pets');
      await page.waitForURL('**/auth**');
      expect(page.url()).toContain('/auth');
    });

    test('redirects unauthenticated user to /auth when accessing /vacinas', async ({ page }) => {
      await page.goto('/vacinas');
      await page.waitForURL('**/auth**');
      expect(page.url()).toContain('/auth');
    });
  });

  test.describe('Login with credentials', () => {
    test('shows an error for wrong password', async ({ page }) => {
      const loginPage = new LoginPage(page);
      await loginPage.goto();
      await loginPage.login(TEST_EMAIL, 'definitelyWrongPassword!@#');

      // Wait for Firebase to respond and UI to update
      await expect(page.getByRole('alert')).toBeVisible({ timeout: 10_000 });
    });

    test('shows an error for invalid email format', async ({ page }) => {
      const loginPage = new LoginPage(page);
      await loginPage.goto();
      await loginPage.fillLoginForm('not-an-email', 'somepassword');
      await loginPage.submitLogin();

      // Firebase rejects the format and returns auth/invalid-email
      await expect(page.getByRole('alert')).toBeVisible({ timeout: 10_000 });
    });

    // NOTE: Successful login test requires valid credentials from E2E_TEST_EMAIL / E2E_TEST_PASSWORD
    // and a pre-verified Firebase account. Mark as conditional to avoid flakiness in CI without creds.
    test('successful login redirects to dashboard', async ({ page }) => {
      test.skip(
        !process.env.E2E_TEST_EMAIL,
        'Skipped: E2E_TEST_EMAIL not set. Provide real credentials to run this test.'
      );

      const loginPage = new LoginPage(page);
      await loginPage.goto();
      await loginPage.login(TEST_EMAIL, TEST_PASSWORD);

      // Should land on dashboard or verify-email depending on account state
      await page.waitForURL(/\/(verify-email)?$/, { timeout: 15_000 });
    });
  });

});
