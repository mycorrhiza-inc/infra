
# Updating a known computer

run the following bash command:
```bash
nix-shell -p '(nixos{}).nixos-rebuild' --cmd "nixos-rebuild switch --flake .#hal9000 --target-host root@<IP_ADDRESS_OF_COMPUTER>"
```
This is wrapped in a nix-shell since nixos-rebuild is only really availible on nixos computers, but if you install nix this should run on anything.

In the case of the current k8s project the command is

```bash
nix-shell -p '(nixos{}).nixos-rebuild' --command "nixos-rebuild switch --flake .#hal9000 --target-host root@137.184.36.185"
```
