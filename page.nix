{ stdenv, lib, typst, dart-sass, source-sans, font-awesome }: 

stdenv.mkDerivation {
  name = "page";

  src = ./.;

  buildInputs = [ (typst.withPackages (p: [p.modern-cv_0_9_0])) dart-sass ];

  TYPST_FONT_PATHS = lib.concatStringsSep ":" [
    source-sans
    font-awesome
  ];

  TYPST_FEATURES="html";

  buildPhase = ''
    typst compile cv.typ
    typst compile --format html index.typ
    sass css/style.scss css/style.css --no-source-map
    typst compile --format html posts/asic-puzzle.typ
    sass css/*.scss --update
  '';

  installPhase = ''
    mkdir -p $out/posts/asic-puzzle
    cp index.html $out
    cp cv.pdf $out
    cp css $out -r
    cp pub $out -r
    cp talks $out -r
    cp profile.jpg $out
    cp profileStyle.jpg $out
    cp equations.svg $out
    cp posts/asic-puzzle.html $out/posts/
    cp posts/asic-puzzle/* $out/posts/asic-puzzle/
  '';
}
