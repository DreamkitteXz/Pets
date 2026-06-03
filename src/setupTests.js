// Global test setup — loaded automatically by CRA's Jest runner.
import '@testing-library/jest-dom';
import { server } from './tests/mocks/server';

// Establish MSW request interception for the full test run
beforeAll(() => server.listen({ onUnhandledRequest: 'warn' }));

// Reset handlers after each test so state doesn't bleed between tests
afterEach(() => server.resetHandlers());

// Clean up after the full suite
afterAll(() => server.close());
