# patch/default.nix
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
  patch_version = "2.7.6";

in
  mkDerivation {
    # target package name overrides here
    name = "patch-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "patch-${patch_version}";

    patch_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/patch/patch-${patch_version}.tar.xz";
      sha256 = "ac610bda97abe0d9f6b7c963255a11dcb196c25e337c61f94e4778d632f1d8fd";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
