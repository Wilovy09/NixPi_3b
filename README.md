# Instalando NixOS en una Pi 3 B+

> [!NOTE]
> Debes tener raspbian instalado.

## Aumentar RAM con SWAP

> [!NOTE]
> Esto no es indispensable pero en el caso de la Raspberry Pi 3 B +, que solo viene con 1GB de RAM es recomendable aumentarlo.

```bash
sudo dphys-swapfile swapoff
```

```bash
sudo nano /etc/dphys-swapfile
```

Cada `1024` es 1GB.

```bash
CONF_SWAPSIZE=1024
```

```bash
sudo dphys-swapfile setup
```

```bash
sudo dphys-swapfile swapon
```

```bash
sudo reboot
```

## Instalación de NixOS

```bash
sudo apt install curl xz-utils git
```

```bash
curl -L https://nixos.org/nix/install | sh
```

4. Copiamos el comando que nos aparece al final de la instalación de nix:

```bash
. /home/wilovy/.nix-profile/etc/profile.d/nix.sh
```

5. Creamos un archivo `~/.config/nix/nix.conf`

```conf
experimental-features = nix-command flakes
```

6. Creamos un archivo `flake.nix` con el siguiente contenido:

```nix
{
  description = "Base system for raspberry pi";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-generators,
    ...
  }: {
    nixosModules = {
      system = {
        disabledModules = [
          "profiles/base.nix"
        ];

        system.stateVersion = "24.11";
      };
      users = {
        users.users = {
          admin = {
            password = "admin123";
            isNormalUser = true;
            extraGroups = ["wheel" "networkmanager"];
          };
        };
      };
    };

    packages.aarch64-linux = {
      sdcard = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "sd-aarch64";
        modules = [
          ./extra-config.nix
          self.nixosModules.system
          self.nixosModules.users
        ];
      };
    };
  };
}
```

7. Creamos otro archivo `extra-config.nix`

```nix
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
```

8. Ahora si corremos el siguiente comando a la altura de nuestro `flake.nix`

```bash
NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix build --impure .#packages.aarch64-linux.sdcard
```

9. Ahora tenemos que cargar ese `.img` que se genero en nuestra micro sd e iniciar la raspberry pi

```bash
nix-channel --update
```

```bash
nixos-generate-config
```

> [!NOTE]
> Si ocupamos conectarnos con wifi lo hacemos con `nmtui`.

> [!NOTE]
> Esto puede tardar varios minutos

```bash
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix
```

10. Modificamos la configuración de nix

```nix

# Agregar config
```

11. Rebuildeamos

```bash
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix
```

12. Cambiamos la contraseña de nuestro nuevo usuario

```bash
passwd USER_DEFINIDO
```

---

[video de donde se saco info](https://www.youtube.com/watch?v=VIuPRL6Ucgk&t=223s)

