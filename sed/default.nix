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
  sed_version = "4.8";

in
  mkDerivation {
    # target package name overrides here
    name = "sed-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "sed-${sed_version}";
    sed_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/sed/sed-4.8.tar.xz";
      sha256 = "0cznxw73fzv1n3nj2zsq6nf73rvsbxndp444xkpahdqvlzz0r6zp";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
