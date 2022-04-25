# ncurses/default.nix
# nix derivation for LFS step1
# to build:  in parent directory:
#   $ nix-build -A ncurses_lfsd_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
# strace               :: storepath     # for debugging
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config, strace }:

let
  ncurses_version = "6.3";

in
  mkDerivation {
    # target package name overrides here
    name = "ncurses-lfsx-stage1";

    gcc_version = "11.2.0";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "ncurses-${ncurses_version}";

    ncurses_src = fetchurl {
      url = "https://invisible-mirror.net/archives/ncurses/ncurses-${ncurses_version}.tar.gz";
      sha256 = "0ng0hhbc4ppw60xa944hgqhvq6n248qjqkgg67g4qp885fn53z4p";
    };

    buildInputs = [
      pkg-config
      strace
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix


