{ config, pkgs, lib, ... }: {
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
      # Kubernetes Packages
    docker-compose
  ];
  
}
