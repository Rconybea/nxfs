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
  gzip_version = "1.11";

in
  mkDerivation {
    # target package name overrides here
    name = "gzip-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "gzip-${gzip_version}";

    gzip_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/gzip/gzip-${gzip_version}.tar.xz";
      sha256 = "01vrly90rvc98af6rcmrb3gwv1l6pylasvsdka23dffwizb9b6lv";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
