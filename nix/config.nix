# ./config.nix
{ config, pkgs, lib, ... }: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  system.activationScripts.copyInitScript = lib.stringAfter [ "users" ] ''
    mkdir -p /mycorrhiza/
    cp ${../misc-setup.sh} /mycorrhiza/misc-setup.sh
    chmod +x /mycorrhiza/misc-setup.sh
    chown root:mycorrhiza /mycorrhiza -R
    chmod 775 /mycorrhiza -R
  '';
  users.users.mirri = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "mycorrhiza" ];
    # TODO: If you could throw in your ssh key, set your shell that would be great!
    # shell = pkgs.fish;
  };
  users.users.nicole = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "mycorrhiza" ];
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
  # swapDevices = [{
  #   device = "/swap/swapfile";
  #   size = 1024 * 2; # 2 GB
  # }];
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
  environment.systemPackages = with pkgs; [
      kubernetes-helm



      git
      micro
      btop
      wget
    ];
  programs.git.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor= true;
  };
  programs.fish = {
    enable = true;
  };
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig="set -g mouse on";
  };

  system.stateVersion = "24.11"; # Never change this
}
