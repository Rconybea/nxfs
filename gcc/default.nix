# gcc/default.nix
# nix derivation for LFS step1
# to build:  in parent directory:
#   $ nix-build -A gcc_lfsx_stage1
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
    name = "gcc-lfsx-stage1";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    glibc_version = "2.35";

    binutils_vsubdir = "binutils-2.38";

    binutils_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.xz";
      sha256 = "0970ry708ffcxnnbndld4085l3wbbdw2jpadqg67wmjgj5x4f5p3";
    };

    mpfr_vsubdir = "mpfr-4.1.0";

    mpfr_src = fetchurl {
      url = "https://www.mpfr.org/mpfr-4.1.0/mpfr-4.1.0.tar.xz";
      sha256 = "0zwaanakrqjf84lfr5hfsdr7hncwv9wj0mchlr7cmxigfgqs760c";
    };

    gmp_vsubdir = "gmp-6.2.1";

    gmp_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz";
      sha256 = "1wml97fdmpcynsbw9yl77rj29qibfp652d0w3222zlfx5j8jjj7x";
    };

    mpc_vsubdir = "mpc-1.2.1";

    mpc_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz";
      sha256 = "0n846hqfqvmsmim7qdlms0qr86f1hck19p12nq3g3z2x74n3sl0p";
    };

    vsubdir = "gcc-${gcc_version}";

    gcc_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.xz";
      sha256 = "12zs6vd2rapp42x154m479hg3h3lsafn3xhg06hp5hsldd9xr3nh";
    };

    # directory for the 'attr' dev package
    #attrDevDir = with pkgs; (pkgs.lib.getDev attr);

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

