{ stdenv, lib, typst, sass, source-sans, font-awesome }:

stdenv.mkDerivation {
  name = "page";

  src = ./.;

  buildInputs = [ (typst.withPackages (p: [p.modern-cv_0_9_0])) sass ];

  TYPST_FONT_PATHS = lib.concatStringsSep ":" [
    source-sans
    font-awesome
  ];

  TYPST_FEATURES="html";

  buildPhase = ''
    typst compile cv.typ
    typst compile --format html index.typ
    sass css/*.scss --update
  '';

  installPhase = ''
    mkdir -p $out
    cp index.html $out
    cp cv.pdf $out
    cp css $out -r
    cp pub $out -r
    cp talks $out -r
    cp profile.jpg $out
    cp profileStyle.jpg $out
    cp equations.svg $out
  '';
}
