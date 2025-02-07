{ config, pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
      # Kubernetes Packages
      kubernetes-helm
  ];

  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--debug" # Optionally add additional args to k3s
  ];
}
