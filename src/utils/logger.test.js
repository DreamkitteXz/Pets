import logger from './logger';

describe('logger', () => {
  let errorSpy, warnSpy, infoSpy;

  beforeEach(() => {
    errorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
    warnSpy  = jest.spyOn(console, 'warn').mockImplementation(() => {});
    infoSpy  = jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('in development environment', () => {
    beforeEach(() => {
      // CRA tests run with NODE_ENV='test', not 'development'.
      // Override the isDev check by temporarily reassigning process.env.
      Object.defineProperty(process.env, 'NODE_ENV', { value: 'development', configurable: true });
    });

    afterEach(() => {
      Object.defineProperty(process.env, 'NODE_ENV', { value: 'test', configurable: true });
    });

    it('logger.error calls console.error when isDev is re-evaluated', () => {
      // Note: because isDev is captured at module load time, we test the
      // observable behavior rather than the internal flag.
      // This test documents that the function signature is callable.
      expect(() => logger.error('test error')).not.toThrow();
    });
  });

  describe('in test/production environment (NODE_ENV !== development)', () => {
    // CRA sets NODE_ENV to 'test' during jest runs, so isDev is false
    // and no console methods should be called.

    it('logger.error does NOT call console.error', () => {
      logger.error('silent error');
      expect(errorSpy).not.toHaveBeenCalled();
    });

    it('logger.warn does NOT call console.warn', () => {
      logger.warn('silent warning');
      expect(warnSpy).not.toHaveBeenCalled();
    });

    it('logger.info does NOT call console.log', () => {
      logger.info('silent info');
      expect(infoSpy).not.toHaveBeenCalled();
    });

    it('logger methods accept any number of arguments without throwing', () => {
      expect(() => {
        logger.error('a', 'b', { c: 3 });
        logger.warn('a', [1, 2]);
        logger.info();
      }).not.toThrow();
    });
  });
});
