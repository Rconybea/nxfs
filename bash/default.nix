# bash/default.nix
# nix derivation for LFS step1
# to build:  in parent directory:
#   $ nix-build -A bash_lfsx_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config }:

let
  bash_version = "5.1.16";

in
  mkDerivation {
    # target package name overrides here
    name = "bash-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "bash-${bash_version}";

    bash_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/bash/bash-${bash_version}.tar.gz";
      sha256 = "0n7mja0izgh6b6jspqcsq3hl9fasz38krlfs412q649rilhigb2v";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix


