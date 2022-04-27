# stdc++/default.nix
# nix derivation for LFS step1
# to build:  in parent directory:
#   $ nix-build -A stdcpp_lfsx_stage1
#

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config }:

let 
  # note: any change to the version suffix must coordinate with glibc/default.nix
  gcc_version = "11.2.0";

in
  mkDerivation {
    # target package name overrides here
    name = "stdc++-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    vsubdir = "gcc-${gcc_version}";

    gcc_version = "${gcc_version}";

    gcc_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/gcc-${gcc_version}.tar.xz";
      sha256 = "12zs6vd2rapp42x154m479hg3h3lsafn3xhg06hp5hsldd9xr3nh";
    };

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

