# ./iso-builder.nix
{ config, pkgs, inputs, ... }: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
  ];

  # Use more aggressive compression then the default.
  virtualisation.digitalOceanImage.compressionMethod = "bzip2";
  
  # ...
}
