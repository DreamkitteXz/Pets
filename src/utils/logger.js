const isDev = process.env.NODE_ENV === 'development';

const logger = {
  error: (...args) => { if (isDev) console.error(...args); },
  warn:  (...args) => { if (isDev) console.warn(...args); },
  info:  (...args) => { if (isDev) console.log(...args); },
};

export default logger;
