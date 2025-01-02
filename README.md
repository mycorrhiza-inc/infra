# Get Started 
Install Nix, using instructions here: https://nixos.org/download/ or just run the command:
```bash 
sh <(curl -L https://nixos.org/nix/install)
```
on mac or linux.
# Build the image 
Run the following command.
```bash 
nix build .#nixosConfigurations.hal9000.config.system.build.digitalOceanImage
```
The output image should be visible in results/

# Updating an already built computer.

run the following bash command:
```bash
nix-shell -p '(nixos{}).nixos-rebuild' --cmd "nixos-rebuild switch --flake .#hal9000 --target-host root@<IP_ADDRESS_OF_COMPUTER>"
```
This is wrapped in a nix-shell since nixos-rebuild is only really availible on nixos computers, but wrapping it lets you run it on any computer you can install nix on.

In the case of the current k8s project the command is

```bash
nix-shell -p '(nixos{}).nixos-rebuild' --command "nixos-rebuild switch --flake .#hal9000 --target-host root@137.184.36.185"
```

# Update System Packages 

run 
```bash
nix flake update --commit-lock file
```
then push the changes and update existing systems with the commands above.
