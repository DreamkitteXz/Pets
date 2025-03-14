export const PUBLIC_ROUTES = {
  AUTH: '/auth',
  FORGOT_PASSWORD: '/forgot-password',
  RESET_PASSWORD: '/reset-password',
  VERIFY_EMAIL: '/verify-email',
  UNAUTHORIZED: '/unauthorized',
};

export const PROTECTED_ROUTES = {
  DASHBOARD: '/',
  PETS: {
    LIST: '/pets',
    DETAILS: (id) => `/pets/${id}`,
  },
  VACCINES: {
    LIST: '/vaccines',
    DETAILS: (id) => `/vaccines/${id}`,
  },
  PROFILE: '/profile',
  SETTINGS: '/settings',
  COMPLETE_PROFILE: '/complete-profile',
};

export const ERROR_ROUTES = {
  NOT_FOUND: '/404',
};
