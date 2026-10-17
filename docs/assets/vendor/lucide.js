const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = plugin(function ({ matchComponents, theme }) {
  let iconsDir = path.join(__dirname, "../../deps/lucide/icons")
  let values = {}

  fs.readdirSync(iconsDir).forEach((file) => {
    if (!file.endsWith(".svg")) return

    let name = path.basename(file, ".svg")
    values[name] = { name, fullPath: path.join(iconsDir, file) }
  })

  matchComponents(
    {
      lucide: ({ name, fullPath }) => {
        let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
        content = encodeURIComponent(content)
        // FlintUI's `<.icon>` owns the box: it exposes `--fl-icon-size`, which a
        // control (button/toggle) can override to size the icon it wraps. Fall
        // back to 24px when nothing sets the variable, so an icon used without a
        // size still renders.
        let size = theme("spacing.6")

        return {
          [`--lucide-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--lucide-${name})`,
          "-webkit-mask-repeat": "no-repeat",
          "-webkit-mask-size": "contain",
          "-webkit-mask-position": "center",
          mask: `var(--lucide-${name})`,
          "mask-repeat": "no-repeat",
          "mask-size": "contain",
          "mask-position": "center",
          "background-color": "currentColor",
          "vertical-align": "middle",
          display: "inline-block",
          width: `var(--fl-icon-size, ${size})`,
          height: `var(--fl-icon-size, ${size})`,
        }
      },
    },
    { values },
  )
})
