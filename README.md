# Jingren Wang — Personal Website

A static academic website built with [Typst](https://typst.app/) and [Nix](https://nixos.org/), deployed to GitHub Pages via GitHub Actions.

## Quick Start (Local Preview)

### Prerequisites

```bash
brew install typst
```

### Build and Serve

```bash
./build.sh
```

Open `http://localhost:4000`.

### Manual Build

```bash
typst compile --features html --format html index.typ
typst compile cv.typ
sass css/style.scss css/style.css --no-source-map
```

## Project Structure

| File | Purpose |
|---|---|
| `index.typ` | Main page content and layout |
| `data.typ` | Structured data for talks, publications, coauthors |
| `cv.typ` | CV rendered with `modern-cv` Typst package |
| `css/style.scss` | Site styles (Dracula theme) |
| `css/colours.scss` | Color palette variables |
| `equations.svg` | Boolean algebra background pattern |
| `build.sh` | Local build and preview script |
| `flake.nix` / `page.nix` | Nix build for CI |
| `.github/workflows/pages.yml` | GitHub Actions deployment |


## Credits

Template adapted from [Alex Rice](https://alexarice.github.io).
