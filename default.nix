{ nixpkgs ? import <nixpkgs> {} }:

#with nixpkgs;

let
  allPkgs = nixpkgs // pkgs;

  callPackage = path: overrides:
    let
      f = import path;
    in
      f ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);

  # mkDerivation :: (set -> derivation)
  mkDerivation = import nix-support/autotools.nix nixpkgs;

  # adds locally-defined user pkgs
  pkgs = rec {
    inherit mkDerivation;

    # need also pkgs.fetchurl

    # listing packages below in build order
    # i.e. dependency-providers before dependency-users
    #
    # callPackage relpath overrides
    #   relpath:     use relpath/default.nix to compute derivation
    #                relpath/default.nix should produce a function,
    #                with formal parameters that are nix package names;
    #                such package names will be resolved here
    #   overrides:   overrides for derivation attributes
    #
    hello = callPackage ./hello {};

    # note: abandoned,  using binutils combined with gcc
    binutils_lfsx_stage1 = callPackage ./binutils {};
    # builds binutils+gcc, output to nix store
    gcc_lfsx_stage1 = callPackage ./gcc { lfs-direct = false; };
    # binutils+gcc, output to /mnt/lfs/tools
    gcc_lfsd_stage1 = callPackage ./gcc { lfs-direct = true; };

    # kernel headers, output to nix store
    linux_lfsx_stage1 = callPackage ./linux { lfs-direct = false; };
    # kernel headers, output to /mnt/lfs/usr
    linux_lfsd_stage1 = callPackage ./linux { lfs-direct = true; };

    # glibc, output to nix store
    glibc_lfsx_stage1 = callPackage ./glibc { lfs-direct = false; };

    # glibc, output to /mnt/lfs
    #
    # note: we can't use lfsx/lfsd codebases as deps here,  because they're not buildable by
    # nix-build.   Instead we're relying on them having been installed to /mnt/lfs
    # via nix-shell.
    glibc_lfsd_stage1 = callPackage ./glibc { lfs-direct = true; gcc_lfsx_stage1 = false; linux_lfsx_stage1 = false; };

    # stdc++, output to /mnt/lfs
    stdcpp_lfsd_stage1 = callPackage ./stdc++ { lfs-direct = true; };

    # m4, output to /mnt/lfs
    m4_lfsd_stage1 = callPackage ./m4 { lfs-direct = true; };

    # ncurses, output to /mnt/lfs
    ncurses_lfsd_stage1 = callPackage ./ncurses { lfs-direct = true; };

    # bash, output to /mnt/lfs
    bash_lfsd_stage1 = callPackage ./bash { lfs-direct = true; };

    # coreutils, output to /mnt/lfs
    coreutils_lfsd_stage1 = callPackage ./coreutils { lfs-direct = true; };

    # diffutils, output to /mnt/lfs
    diffutils_lfsd_stage1 = callPackage ./diffutils { lfs-direct = true; };

    # file, output to /mnt/lfs
    file_lfsd_stage1 = callPackage ./file { lfs-direct = true; };

    # findutils, output to /mnt/lfs
    findutils_lfsd_stage1 = callPackage ./findutils { lfs-direct = true; };

    # gawk, output to /mnt/lfs
    gawk_lfsd_stage1 = callPackage ./gawk { lfs-direct = true; };

    # grep, output to /mnt/lfs
    grep_lfsd_stage1 = callPackage ./grep { lfs-direct = true; };

    # gzip, output to /mnt/lfs
    gzip_lfsd_stage1 = callPackage ./gzip { lfs-direct = true; };

    # make, output to /mnt/lfs
    make_lfsd_stage1 = callPackage ./make { lfs-direct = true; };

    # patch, output to /mnt/lfs
    patch_lfsd_stage1 = callPackage ./patch { lfs-direct = true; };

    fhs_stage1 = callPackage ./fhs_stage1 {};

    inherit nixpkgs;  # allows callers to use the nixpkgs version defined here
  };
in
  pkgs
  
  