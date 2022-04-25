# findutils/default.nix
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
  findutils_version = "4.9.0";

in
  mkDerivation {
    # target package name overrides here
    name = "findutils-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "findutils-${findutils_version}";

    findutils_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/findutils/findutils-${findutils_version}.tar.xz";
      sha256 = "1zk2sighc26bfdsm97bv7cd1cnvq7r4gll4zqpnp0rs3kp0bigx2";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

# end default.nix
