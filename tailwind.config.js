/** @type {import('tailwindcss').Config} */

module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        brand: {
          dark: '#032b43',
          light: '#f0f4f3',
          blue: '#80c3e8',
          orange: '#cb8657',
        },
        color_var: {
          default: '#90B494',
        },
      },
      fontFamily: {
        sans: [
          '-apple-system', 'SF Pro Display', 'SF Pro Text', 'BlinkMacSystemFont',
          'Inter', 'Segoe UI', 'Roboto', 'sans-serif',
        ],
        'alfa-slab': ['"Alfa Slab One"', 'serif'],
        montserrat: ['Montserrat', 'sans-serif'],
        roboto: ['Roboto', 'sans-serif'],
        inter: ['Inter', 'sans-serif'],
      },
      transitionDuration: {
        600: '600ms',
      },
    },
  },
  plugins: [],
};
