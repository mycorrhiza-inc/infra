# ./configuration.nix
{ config, pkgs, lib, ... }: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.mirri = {
    extraGroups  = [ "wheel" "networkmanager" ];
    # TODO: If you could throw in your ssh key, set your shell that would be great!
    # shell = pkgs.fish;
  };
  users.users.nicole = {
    extraGroups  = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdPzSlJ3TCzPy7R2s2OOBJbBb+U5NY8dwMlGH9wm4Ot nicole@apiarist"
    ];
    shell = pkgs.fish;
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdPzSlJ3TCzPy7R2s2OOBJbBb+U5NY8dwMlGH9wm4Ot nicole@apiarist"
    ];
    shell = pkgs.fish;
    # Altough optional, setting a root password allows you to
    # open a terminal interface in DO's website.
    # hashedPassword = 
    #   "generate a hashed password with the mkpasswd command";
  };

  # You should always have some swap space,
  # This is even more important on VPSs
  # The swapfile will be created automatically.
  swapDevices = [{
    device = "/swap/swapfile";
    size = 1024 * 2; # 2 GB
  }];
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--debug" # Optionally add additional args to k3s
  ];
  enviornment.systemPackages = with pkgs; [
      helm



      git
      fish
      micro
      neovim
      btop
      wget
    ];
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig="set -g mouse on";
  };

  system.stateVersion = "23.05"; # Never change this
}
