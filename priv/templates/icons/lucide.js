const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = plugin(function ({ matchComponents, theme }) {
  let iconsDir = path.join(__dirname, "../../deps/lucide_icons/icons");

  if (!fs.existsSync(iconsDir)) {
    console.warn(
      `[flint_ui] Lucide icons not found at ${iconsDir}. Run "mix deps.get".`,
    );
    return;
  }

  let values = {};

  fs.readdirSync(iconsDir).forEach((file) => {
    if (!file.endsWith(".svg")) return;

    let name = path.basename(file, ".svg");
    values[name] = { name, fullPath: path.join(iconsDir, file) };
  });

  matchComponents(
    {
      lucide: ({ name, fullPath }) => {
        let content = fs
          .readFileSync(fullPath)
          .toString()
          .replace(/\r?\n|\r/g, "")
          .replace(/\s(?:width|height)="24"/g, "")
          .replace(/stroke-width="2"/g, 'stroke-width="1.5"')
          .replace(/stroke="[^"]+"/g, 'stroke="currentColor"');

        content = encodeURIComponent(content);

        let size = theme("spacing.6");

        return {
          [`--lucide-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--lucide-${name}) center / contain no-repeat`,
          mask: `var(--lucide-${name}) center / contain no-repeat`,
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
