/**
 * E2E — Navigation and error page flows.
 * These tests do NOT require authentication.
 */
const { test, expect } = require('@playwright/test');
const { LoginPage } = require('../pages/LoginPage');

test.describe('Public pages', () => {

  test('Landing page loads at /home', async ({ page }) => {
    await page.goto('/home');
    // Landing has the hero heading "Pets."
    await expect(page.locator('h1, [class*="hero"]').first()).toBeVisible({ timeout: 10_000 });
  });

  test('Auth page loads at /auth', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await expect(loginPage.emailInput()).toBeVisible();
  });

  test('404 page renders for unknown routes', async ({ page }) => {
    await page.goto('/this-route-does-not-exist');
    await expect(page.getByText(/página não encontrada/i)).toBeVisible({ timeout: 10_000 });
  });

  test('404 page has a working "Ir para o início" button', async ({ page }) => {
    await page.goto('/nonexistent');
    await page.getByRole('button', { name: /ir para o início/i }).click();
    // Should navigate to / which then redirects to /auth because user is not logged in
    await page.waitForURL(/\/(auth)?$/, { timeout: 10_000 });
  });

  test('Unauthorized page loads at /unauthorized', async ({ page }) => {
    await page.goto('/unauthorized');
    await expect(page.getByText(/acesso negado/i)).toBeVisible({ timeout: 10_000 });
  });

  test('Unauthorized page has a working login button', async ({ page }) => {
    await page.goto('/unauthorized');
    await page.getByRole('button', { name: /fazer login/i }).click();
    await page.waitForURL('**/auth**', { timeout: 10_000 });
  });

});

test.describe('Forgot password page', () => {
  test('loads at /forgot-password', async ({ page }) => {
    await page.goto('/forgot-password');
    // Page should exist and have some identifiable content
    await expect(page.locator('body')).toBeVisible();
    // Should not redirect to 404
    await expect(page.url()).not.toContain('404');
  });
});
