# gawk/default.nix
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
  gawk_version = "5.1.1";

in
  mkDerivation {
    # target package name overrides here
    name = "gawk-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "gawk-${gawk_version}";

    gawk_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/gawk/gawk-5.1.1.tar.xz";
      sha256 = "18kybw47fb1sdagav7aj95r9pp09r5gm202y3ahvwjw9dqw2jxnq";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
