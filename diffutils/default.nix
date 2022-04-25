# bash/default.nix
# nix derivation for LFS step1
# to build:  in parent directory:
#   $ nix-build -A diffutils_lfsx_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config }:

let
  diffutils_version = "3.8";

in
  mkDerivation {
    # target package name overrides here
    name = "diffutils-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "diffutils-${diffutils_version}";

    diffutils_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/diffutils/diffutils-${diffutils_version}.tar.xz";
      sha256 = "1v4g8gi0lgakqa7iix8s4fq7lq6l92vw3rjd9wfd2rhjng8xggd6";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
