# bash/default.nix
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
  coreutils_version = "9.0";

in
  mkDerivation {
    # target package name overrides here
    name = "coreutils-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "coreutils-${coreutils_version}";

    coreutils_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/coreutils/coreutils-${coreutils_version}.tar.xz";
      sha256 = "1klp7dxkqhrjxn4qic6ywfs1d8jzlzmfjmfr1nrmpg219bgsqc6f";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
