# gzip/default.nix
# nix derivation for LFS step1
# to build:  in parent directory:
#   $ nix-build -A coreutils_lfsx_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config }:

let
  make_version = "4.3";

in
  mkDerivation {
    # target package name overrides here
    name = "make-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "make-${make_version}";

    make_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/make/make-${make_version}.tar.gz";
      sha256 = "06cfqzpqsvdnsxbysl5p2fgdgxgl9y4p7scpnrfa8z2zgkjdspz0";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
