/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{elm,js,json}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#ea3a60',
        primaryDark: '#ea0032',
        dark: '#171717',
        bg: '#ffffff',
        textDark: '#1d1d1d',
      },
      fontFamily: {
        sans: ['Poppins', 'sans-serif'],
        display: ['Montserrat', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
