# AGENTS.md

Guidance for AI coding agents working in this repository.

**Read `.github/copilot-instructions.md` in full before making changes.**
That file is the single source of truth. It covers the repo layout,
Jekyll/Minima setup, brand colors and typography, the WordPress -> Jekyll
migration workflow, mobile/responsive requirements, and deployment. This
file is a thin pointer so any agent (not just Copilot) picks it up.

## Quick facts
- Static site: **Jekyll 3.10.0** via the `github-pages` gem; **Minima**
  theme (customized); hosted on **GitHub Pages**.
- Base URL: `/nourishingfoodmarketing`.
- Typography: headings and the top nav use **Libre Baskerville** (serif,
  uppercase, letter-spaced); body copy is **Roboto** (light). All style
  overrides live in `_sass/minima.scss` (compiled to `assets/main.css`).
- Local dev: `bundle exec jekyll serve`. GitHub Pages rebuilds
  automatically on push to `main`.

See `.github/copilot-instructions.md` for everything else.
