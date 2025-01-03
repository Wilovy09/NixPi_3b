{ config, lib, pkgs, ... }:
{
  networking.firewall.enable = false;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
       openssh
  ];

  services.openssh.enable = true;
}

