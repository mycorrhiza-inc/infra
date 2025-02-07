# ./config.nix
{ config, pkgs, lib, ... }: {
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  # Disable for testing, almost certainly a good idea to disable later for extra security.
  networking.firewall.enable = false;

  # TODO: Fix this hacky bullshit that preserves the secret config. Using a nixos specific secret management system, or even better a k8s native thing using something like h_____orp vault.
  users.users.mirri = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "mycorrhiza" ];
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkCS1Kf51bfGco61EgRRip+cfLye1kOKSyH/qlBYXsi marcusbrightxyz@gmail.com"
    ];
    # TODO: If you could throw in your ssh key, set your shell that would be great!
    shell = pkgs.fish;
    # You can also use zsh or whatever you want, if you would like to enable it write programs.zsh.enable = true;
    # In general options documentation is availible here: https://search.nixos.org/options?channel=24.11
  };
  users.users.nicole = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "networkmanager" "mycorrhiza" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdPzSlJ3TCzPy7R2s2OOBJbBb+U5NY8dwMlGH9wm4Ot nicole@apiarist"
    ];
    initialPassword = "changeme";
    shell = pkgs.fish;
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdPzSlJ3TCzPy7R2s2OOBJbBb+U5NY8dwMlGH9wm4Ot nicole@apiarist"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkCS1Kf51bfGco61EgRRip+cfLye1kOKSyH/qlBYXsi marcusbrightxyz@gmail.com"
    ];
    shell = pkgs.fish;
  };

  services.tailscale.enable = true;
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  # Necessary to get helm to interact with k3s and not check the default port for k8s
  environment.variables = {
    KUBECONFIG="/etc/rancher/k3s/k3s.yaml";
  };
  environment.systemPackages = with pkgs; [
      # Kubernetes Packages
      kubernetes-helm
      # Misc Nice to have Stuff 
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
  # You should always have some swap space,
  # This is even more important on VPSs
  # The swapfile will be created automatically.
  # swapDevices = [{
  #   device = "/swap/swapfile";
  #   size = 1024 * 2; # 2 GB
  # }];

  system.activationScripts.copyInfrastructureScripts = lib.stringAfter [ "users" ] ''
    mkdir -p /mycorrhiza/
    if [ -f /mycorrhiza/infra/infra/helm/templates/secret.yaml ]; then
      mv /mycorrhiza/infra/infra/helm/templates/secret.yaml /mycorrhiza/secret.yaml.tmp
    fi
    rm -rf /mycorrhiza/infra
    cp -r ${../.} /mycorrhiza/infra
    if [ -f /mycorrhiza/secret.yaml.tmp ]; then
      mkdir -p /mycorrhiza/infra/infra
      mv /mycorrhiza/secret.yaml.tmp /mycorrhiza/infra/helm/templates/secret.yaml
    fi
    mkdir -p /mycorrhiza/infra/
    chown root:mycorrhiza /mycorrhiza -R
    chmod 775 /mycorrhiza -R
  '';

  system.stateVersion = "24.11"; # Never change this
}
