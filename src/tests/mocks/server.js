import { setupServer } from 'msw/node';
import { handlers } from './handlers';

// Shared MSW server instance — started/stopped in setupTests.js
export const server = setupServer(...handlers);
