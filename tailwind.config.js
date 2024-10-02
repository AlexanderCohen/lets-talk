const colors = require("tailwindcss/colors");

module.exports = {
  plugins: [
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/line-clamp"),
    require("@tailwindcss/typography"),
    function ({ addUtilities }) {
      const newUtilities = {
        ".no-scrollbar::-webkit-scrollbar": {
          display: "none",
        },
        ".no-scrollbar": {
          "-ms-overflow-style": "none",
          "scrollbar-width": "none",
        },
      };
      addUtilities(newUtilities);
    }
  ],

  content: [
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.erb",
    "./app/views/**/*.haml",
    "./app/views/**/*.slim",
  ],

  theme: {
    // Create your own at: https://javisperez.github.io/tailwindcolorshades
    extend: {
      colors: {
        primary: colors.indigo,
        secondary: colors.emerald,
        tertiary: colors.gray,
        danger: colors.red,
      },
      // fontFamily: {
      //   sans: ["Inter", ...defaultTheme.fontFamily.sans],
      // },
      animation: {
        'spin-slow': 'spin 5s ease-in-out infinite',
        'rotate': "rotate 10s linear infinite",
        'l4': 'l4 1.5s infinite alternate ease-in-out',
      },
      keyframes: {
        rotate: {
          "0%": { transform: "rotate(0deg) scale(10)" },
          "100%": { transform: "rotate(-360deg) scale(10)" },
        },
        l4: {
          '0%': { width: '150px', aspectRatio: '4 / 1' },
          '100%': { width: '50px', aspectRatio: '1 / 1' },
        },
      },
    },
  }
}
