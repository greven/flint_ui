const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = plugin(function ({ matchComponents, theme }) {
  let iconsDir = path.join(__dirname, "../../deps/phosphor_icons/assets");

  if (!fs.existsSync(iconsDir)) {
    console.warn(
      `[flint_ui] Phosphor icons not found at ${iconsDir}. Run "mix deps.get".`,
    );
    return;
  }

  // Every weight is its own SVG geometry and its own file; the regular weight
  // has no suffix and the rest already end in their weight name.
  let weights = ["regular", "thin", "light", "bold", "fill", "duotone"];
  let values = {};

  weights.forEach((weight) => {
    fs.readdirSync(path.join(iconsDir, weight)).forEach((file) => {
      if (!file.endsWith(".svg")) return;

      let name = path.basename(file, ".svg");
      values[name] = { name, fullPath: path.join(iconsDir, weight, file) };
    });
  });

  matchComponents(
    {
      ph: ({ name, fullPath }) => {
        let content = fs
          .readFileSync(fullPath)
          .toString()
          .replace(/\r?\n|\r/g, "")
          .replace(/\s(?:width|height)="\d+"/g, "")
          .replace(/fill="[^"]+"/g, 'fill="currentColor"');

        content = encodeURIComponent(content);

        let size = theme("spacing.6");

        return {
          [`--ph-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--ph-${name}) center / contain no-repeat`,
          mask: `var(--ph-${name}) center / contain no-repeat`,
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
