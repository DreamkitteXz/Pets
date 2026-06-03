/**
 * Page Object Model for the /auth route.
 * All selectors are encapsulated here; spec files never use raw locators.
 */
export class LoginPage {
  constructor(page) {
    this.page = page;
  }

  async goto() {
    await this.page.goto('/auth');
  }

  // ── Locators ──────────────────────────────────────────────────────────────

  emailInput()    { return this.page.getByLabel(/seu email/i); }
  passwordInput() { return this.page.getByLabel(/^senha$/i); }
  submitButton()  { return this.page.getByRole('button', { name: /entrar/i }); }
  googleButton()  { return this.page.getByRole('button', { name: /entrar com google/i }); }
  errorAlert()    { return this.page.getByRole('alert'); }
  signUpToggle()  { return this.page.getByRole('button', { name: /cadastre-se/i }); }

  // Sign-up specific fields (visible only when in sign-up mode)
  nameInput()           { return this.page.getByLabel(/nome completo/i); }
  confirmPasswordInput(){ return this.page.getByLabel(/confirmar senha/i); }
  signUpButton()        { return this.page.getByRole('button', { name: /começar/i }); }

  // ── Actions ───────────────────────────────────────────────────────────────

  async fillLoginForm(email, password) {
    await this.emailInput().fill(email);
    await this.passwordInput().fill(password);
  }

  async submitLogin() {
    await this.submitButton().click();
  }

  async login(email, password) {
    await this.fillLoginForm(email, password);
    await this.submitLogin();
  }

  async switchToSignUp() {
    await this.signUpToggle().click();
  }

  async fillSignUpForm(name, email, password) {
    await this.nameInput().fill(name);
    await this.emailInput().fill(email);
    await this.passwordInput().fill(password);
    await this.confirmPasswordInput().fill(password);
  }

  // ── Assertions ────────────────────────────────────────────────────────────

  async expectErrorVisible() {
    await this.errorAlert().waitFor({ state: 'visible' });
  }

  async expectErrorContaining(text) {
    await this.expectErrorVisible();
    const content = await this.errorAlert().textContent();
    if (!content.includes(text)) {
      throw new Error(`Expected error to contain "${text}" but got "${content}"`);
    }
  }

  async expectToBeOnLoginPage() {
    await this.page.waitForURL('**/auth**');
  }
}
