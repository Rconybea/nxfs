# m4/default.nix
# nix derivation for LFS step1
# to build:  in parent directory:
#   $ nix-build -A m4_lfsx_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config }:

let
  m4_version = "1.4.19";

in
  mkDerivation {
    # target package name overrides here
    name = "m4-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "m4-${m4_version}";

    m4_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/m4/m4-${m4_version}.tar.xz";
      sha256 = "15mghcksh11saylpm86h1zkz4in0rbi0pk8i6nqxkdikdmfdxbk3";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix


