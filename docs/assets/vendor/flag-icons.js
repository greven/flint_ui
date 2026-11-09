const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = plugin(function ({ matchComponents, theme }) {
  let iconsDir = path.join(__dirname, "../../deps/flag_icons/flags");

  if (!fs.existsSync(iconsDir)) {
    console.warn(
      `[flint_ui] Flag Icons not found at ${iconsDir}. Run "mix deps.get".`,
    );
    return;
  }

  let values = {};
  let icons = [
    ["", "/4x3"],
    ["-square", "/1x1"],
  ];

  icons.forEach(([suffix, dir]) => {
    fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
      if (!file.endsWith(".svg")) return;

      let name = path.basename(file, ".svg") + suffix;
      values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
    });
  });

  matchComponents(
    {
      flag: ({ name, fullPath }) => {
        let content = fs
          .readFileSync(fullPath)
          .toString()
          .replace(/\r?\n|\r/g, "");
        content = encodeURIComponent(content);

        let aspect = name.endsWith("-square") ? "1" : "4 / 3";
        let size = theme("spacing.6");

        return {
          [`--flag-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "background-image": `var(--flag-${name})`,
          "background-repeat": "no-repeat",
          "background-size": "cover",
          "background-position": "center",
          "vertical-align": "middle",
          display: "inline-block",
          "aspect-ratio": aspect,
          width: `var(--fl-flag-size, ${size})`,
        };
      },
    },
    { values },
  );
});
