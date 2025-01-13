{pkgs, ...}: {
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    openssh
    vim
  ];
  
  security.polkit.enable = true;
  services.dbus = {
    enable = true;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 2 * 1024;
    }
  ];

  services.openssh = {
    enable = true;
    ports = [22];
  };
}