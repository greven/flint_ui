import * as esbuild from "esbuild";
import { execSync } from "node:child_process";
import { rmSync } from "node:fs";

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

rmSync("../priv/static", { recursive: true, force: true });

// Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
const loader = {};

// Add and configure plugins here
const plugins = [];

let buildOptions = {
  entryPoints: ["src/index.ts"],
  outfile: "../priv/static/flint.js",
  bundle: true,
  format: "esm",
  platform: "browser",
  target: "es2022",
  external: ["phoenix", "phoenix_live_view"],
  treeShaking: true,
  logLevel: "info",
  loader,
  plugins,
};

if (deploy) {
  buildOptions = { ...buildOptions, minify: true };
}

if (watch) {
  let ctx = await esbuild.context({ ...buildOptions, sourcemap: "inline" });
  await ctx.watch();
  process.stdout.write("Watching for changes...\n");
} else {
  esbuild.build(buildOptions);
  execSync("tsc --emitDeclarationOnly", { stdio: "inherit" });
}
