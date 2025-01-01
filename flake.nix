{
  # inputs MUST be an Attribute set that lists the .... You know
  inputs = {
    # Here we declare we need nixpkgs, notice we only say what branch
    # not the exact commit hash, flakes will take care of that 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };
  # outputs MUST be a function that returns an Attribute set.
  # Everything else is just convention, convention that even some
  # Nix commands will assume are true.
  outputs = inputs: {
    # `nix run` and `nix build` will look for this attribute by default
    # `nix run` or `nix run .#default` should print "Hello world"

    # You can switch to the system described in ./configuration with
    # `nixos-rebuild switch --flake .#hal9000`
    nixosConfigurations.hal9000 = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        # remember "inherit x;" is the same as "x = x;"
        inherit inputs; 
      };
      system = "x86_64-linux";
      modules = [ ./nix/config.nix ./nix/iso-builder.nix ];


    };
  };
}
