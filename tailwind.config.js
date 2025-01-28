/** @type {import('tailwindcss').Config} */
 
module.exports = {
  content: [ "./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        color_var: {
          default: '#90B494',
        }
      }
    },
  },
  plugins: [],
}

