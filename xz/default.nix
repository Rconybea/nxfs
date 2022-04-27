# xz/default.nix
# nix derivation for LFS step1
# to build:
#   $ ./lfs-build.sh    # directly to /mnt/lfs
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config }:

let
  xz_version = "5.2.5";

in
  mkDerivation {
    # target package name overrides here
    name = "xz-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "xz-${xz_version}";
    xz_src = fetchurl {
      url = "https://tukaani.org/xz/xz-${xz_version}.tar.xz";
      sha256 = "3e1e518ffc912f86608a8cb35e4bd41ad1aec210df2a47aaa1f95e7f5576ef56";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
