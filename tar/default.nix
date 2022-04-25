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
  tar_version = "1.34";

in
  mkDerivation {
    # target package name overrides here
    name = "tar-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "tar-${tar_version}";
    tar_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/tar/tar-${tar_version}.tar.xz";
      sha256 = "63bebd26879c5e1eea4352f0d03c991f966aeb3ddeb3c7445c902568d5411d28";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
