# binutils/default.nix
# nix derivation for LFS step1

{ mkDerivation, fetchurl, pkg-config }:

mkDerivation {
  name = "binutils-lfsx-stage1";

  args = [ ./builder.sh ];
  setup = ./setup.sh;

  # unpacking tarball creates this subdir
  vsubdir = "binutils-2.38";

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.xz";
    sha256 = "0970ry708ffcxnnbndld4085l3wbbdw2jpadqg67wmjgj5x4f5p3";
  };

  buildInputs = [
    pkg-config
    #(pkgs.lib.getLib attr)
    #(pkgs.lib.getDev attr)
  ];
}

