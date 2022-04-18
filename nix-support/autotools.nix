# i.e. lambda pkgs . lambda attrs . (with pkgs ... )
# expected to be invoked like
#   let mkDerivation = import path/to/autotools.nix pkgs;
# in
#   mkDerivation { ... };
# 
pkgs: attrs:
  # any attributes supplied in argument attrs replace the default values below
  with pkgs;

  let
    lfsAttrs = import ./lfs.nix {};
    
    # attributes below will be passed as environment variables
    # to ${codebase}/builder.sh,  after overriding at least
    #   .name, .args, .setup
    # for example see nxfs/hello/{default.nix, setup.sh}
    #
    defaultAttrs = {
      name = "please-override-name";

      lfs_mount = lfsAttrs.lfs.mount;
      lfs_target_suffix = lfsAttrs.lfs.targetSuffix;

      builder = "${bash}/bin/bash";

      # args, setup: these defaults only work
      # if .sh files are in the same directory as this autotools.nix file.
      # expect to override these in ${subsystem}.nix
      #
      args = [ ./stub-builder.sh ];
      setup = ./stub-setup.sh;

      # all autotools builds will get these packages
      # (don't really need 'which',  this is for debugging)
      #
      baseInputs = [ rsync gnumake texinfo gcc binutils-unwrapped gnugrep gawk gnused gnutar xz gzip file diffutils which stdenv coreutils findutils ];
      buildInputs = [];

      system = builtins.currentSystem;
    };

    in
    derivation (defaultAttrs // attrs)
  