# stage2/binutils/default.nix
#
# nix derivation for LFS step2
# to build:
#   $ ./lfs-build.sh
#
# ------------------------------------------------------------------------------------------------
# NOTE: in stage1 we built binutils using host compiler,  and installing to /mnt/lfs/tools.
#       now we use the cross-compiler prepared in stage1,  and install to /mnt/lfs/usr
# ------------------------------------------------------------------------------------------------

# mkDerivation         :: (set -> derivation)
# lfs-direct           :: bool
# fetchurl             :: (set(url, sha256) -> path2tarball
# pkg-config           :: storepath
#
{ mkDerivation, lfs-direct, fetchurl, pkg-config }:

let
  binutils_version = "2.38";

  # note: any change to the version suffix must coordinate with:
  #    nxfs/glibc/default.nix
  #
  gcc_version = "11.2.0";

in
  mkDerivation {
    # target package name overrides here
    name = "binutils-lfsx-stage2";

    lfsdirect = lfs-direct;

    args = [ ./builder.sh ];
    setup = ./setup.sh;

    glibc_version = "2.35";

    # note: versions here should match nxfs/gcc/default.nix
    binutils_vsubdir = "binutils-${binutils_version}";

    binutils_src = fetchurl {
      url = "https://ftp.gnu.org/gnu/binutils/binutils-${binutils_version}.tar.xz";
      sha256 = "0970ry708ffcxnnbndld4085l3wbbdw2jpadqg67wmjgj5x4f5p3";
    };

#    mpfr_vsubdir = "mpfr-4.1.0";

#    mpfr_src = fetchurl {
#      url = "https://www.mpfr.org/mpfr-4.1.0/mpfr-4.1.0.tar.xz";
#      sha256 = "0zwaanakrqjf84lfr5hfsdr7hncwv9wj0mchlr7cmxigfgqs760c";
#    };

#    gmp_vsubdir = "gmp-6.2.1";

#    gmp_src = fetchurl {
#      url = "https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz";
#      sha256 = "1wml97fdmpcynsbw9yl77rj29qibfp652d0w3222zlfx5j8jjj7x";
#    };

#    mpc_vsubdir = "mpc-1.2.1";

#    mpc_src = fetchurl {
#      url = "https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz";
#      sha256 = "0n846hqfqvmsmim7qdlms0qr86f1hck19p12nq3g3z2x74n3sl0p";
#    };

#    vsubdir = "gcc-${gcc_version}";

#    gcc_src = fetchurl {
#      url = "https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.xz";
#      sha256 = "12zs6vd2rapp42x154m479hg3h3lsafn3xhg06hp5hsldd9xr3nh";
#    };

    # directory for the 'attr' dev package
    #attrDevDir = with pkgs; (pkgs.lib.getDev attr);

    buildInputs = [
      pkg-config
      #(pkgs.lib.getLib attr)
      #(pkgs.lib.getDev attr)
    ];
  }

