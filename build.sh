#!/usr/bin/env bash
set -e

echo "Compiling HTML..."
typst compile --features html --format html index.typ

echo "Compiling CV..."
typst compile cv.typ

echo "Compiling SCSS..."
sass css/style.scss css/style.css --no-source-map

echo "Compiling blog posts..."
mkdir -p _serve/posts
typst compile --features html --format html posts/asic-puzzle.typ
cp posts/asic-puzzle.html _serve/posts/

mkdir -p _serve
cp index.html _serve/
cp cv.pdf _serve/
cp -r css _serve/
cp -r pub _serve/
cp -r talks _serve/
cp -r posts/asic-puzzle _serve/posts/
cp profileStyle.jpg _serve/
cp equations.svg _serve/

echo "Done. Serving at http://localhost:4000"
cd _serve
python3 -m http.server 4000
