const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = plugin(function ({ matchComponents, theme }) {
  let iconsDir = path.join(__dirname, "../../deps/heroicons/optimized");

  if (!fs.existsSync(iconsDir)) {
    console.warn(
      `[flint_ui] Heroicons not found at ${iconsDir}. Run "mix deps.get".`,
    );
    return;
  }

  let values = {};

  let variants = [
    ["", "/24/outline"],
    ["-solid", "/24/solid"],
    ["-mini", "/20/solid"],
    ["-micro", "/16/solid"],
  ];

  variants.forEach(([suffix, dir]) => {
    fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
      if (!file.endsWith(".svg")) return;

      let name = path.basename(file, ".svg") + suffix;
      values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
    });
  });

  matchComponents(
    {
      hero: ({ name, fullPath }) => {
        let content = fs
          .readFileSync(fullPath)
          .toString()
          .replace(/\r?\n|\r/g, "");
        content = encodeURIComponent(content);

        let size = theme("spacing.6");
        if (name.endsWith("-mini")) size = theme("spacing.5");
        if (name.endsWith("-micro")) size = theme("spacing.4");

        return {
          [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--hero-${name}) center / contain no-repeat`,
          mask: `var(--hero-${name}) center / contain no-repeat`,
          "background-color": "currentColor",
          "vertical-align": "middle",
          display: "inline-block",
          width: `var(--fl-icon-size, ${size})`,
          height: `var(--fl-icon-size, ${size})`,
        };
      },
    },
    { values },
  );
});
