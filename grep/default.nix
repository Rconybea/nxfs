# grep/default.nix
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
  grep_version = "3.7";

in
  mkDerivation {
    # target package name overrides here
    name = "grep-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "grep-${grep_version}";

    grep_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/grep/grep-${grep_version}.tar.xz";
      sha256 = "0g42svbc1nq5bamxfj6x7320wli4dlj86padk0hwgbk04hqxl42w";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
