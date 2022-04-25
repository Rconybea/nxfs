# hello/default.nix

{ mkDerivation, fetchurl }:

mkDerivation {
  name = "hello";

  args = [ ./builder.sh ];
  setup = ./setup.sh;

  # unpacking tarball creates this subdir
  vsubdir = "hello-2.10";

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/hello/hello-2.10.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };

  buildInputs = [];
}
