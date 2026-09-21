# Plank website

Run locally with `bundle exec jekyll serve`. Build with `bundle exec jekyll build`.

## Plank code blocks

Use fenced Markdown blocks tagged `plank` (or `plk`). The custom Rouge lexer in
`_plugins/plank.rb` highlights them at build time, with light/dark colors in
`assets/css/style.css`. No client-side highlighter or extra gems are needed.

The lexer follows the Plank tree-sitter and VS Code grammars in
`../monorepo-plank2/`. When the language changes, update its token rules there.

Custom plugins require a normal Jekyll build, not `--safe`. GitHub Pages' built-in
safe-mode build does not load them; deploy the output of a normal Jekyll build
(e.g. via GitHub Actions) instead.
