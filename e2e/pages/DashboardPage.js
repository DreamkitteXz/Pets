/**
 * Page Object Model for the main dashboard (/).
 */
export class DashboardPage {
  constructor(page) {
    this.page = page;
  }

  async goto() {
    await this.page.goto('/');
  }

  // ── Locators ──────────────────────────────────────────────────────────────

  // KPI cards — identified by the label text beneath the number
  kpiCard(label)   { return this.page.locator('div').filter({ hasText: label }).first(); }
  sidebarLink(name){ return this.page.getByRole('link', { name }); }
  pageHeading()    { return this.page.getByRole('heading', { level: 1 }); }

  // Navigation items
  petsLink()       { return this.sidebarLink(/pacientes/i); }
  vacinasLink()    { return this.sidebarLink(/vacinas/i); }
  profileLink()    { return this.sidebarLink(/perfil/i); }
  settingsLink()   { return this.sidebarLink(/configura/i); }

  // ── Actions ───────────────────────────────────────────────────────────────

  async navigateToPets() {
    await this.petsLink().click();
    await this.page.waitForURL('**/pets**');
  }

  async navigateToVacinas() {
    await this.vacinasLink().click();
    await this.page.waitForURL('**/vacinas**');
  }

  // ── Assertions ────────────────────────────────────────────────────────────

  async expectToBeOnDashboard() {
    await this.page.waitForURL('/');
  }

  async expectGreetingVisible() {
    // Greeting contains "Bom dia", "Boa tarde", or "Boa noite"
    const greeting = await this.page.locator('h1').textContent();
    const hasGreeting = /bom dia|boa tarde|boa noite/i.test(greeting ?? '');
    if (!hasGreeting) throw new Error(`Expected greeting in h1, got: "${greeting}"`);
  }
}
