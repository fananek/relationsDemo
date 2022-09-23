/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["../Views/**/*.{leaf,html,js}"],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms')
  ],
}
