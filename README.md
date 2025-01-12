# Instalando NixOS en una Pi 3 B+

1. Instalamos el `.img` de Raspbian

    - Podemos usar `rpi-imager` o descargar directamente la [iso](https://www.raspberrypi.com/software/operating-systems/) que queremos.
    - Si decidimos descargarla nosotros mismos hay que seguir los siguientes pasos:
    - Descomprimir el `.img.xz` para obtener un `.img`

> [!NOTE]
> Recomiendo usar [ouch](https://github.com/ouch-org/ouch)

```bash
nix-shell -p ouch
ouch decompress NOMBRE_DE_LA_IMAGEN.img.xz
```

- Esto nos generara un archivo `.img`
- Ahora tenemos que cargarlo a nuestra micro sd, para eso usamos el comando y esperamos a que termine

```bash
sudo dd if=2024-11-19-raspios-bookworm-armhf.img of=/dev/sdb bs=4M status=progress
```

- Ahora insertamos nuestra micro sd a nuestra Pi 3 B+

2. Conectarnos a internet.
3. Instalamos:

> [!NOTE]
> Esto puede tardar unos minutos

```bash
sudo apt install curl xz-utils git
curl -L https://nixos.org/nix/install | sh
```

4. Copiamos el comando que nos aparece al final de la instalación de nix:

```bash
. /home/wilovy/.nix-profile/etc/profile.d/nix.sh
```

5. Creamos un archivo `flake.nix` con el siguiente contenido:

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
            extraGroups = ["wheel"];
          };
        };
      };
    };

    packages.aarch64-linux = {
      sdcard = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
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

6. Creamos otro archivo `extra-config.nix`

```nix
{pkgs, ...}: {
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;
  nvironment.systemPackages = with pkgs; [
    vim
    git
    wpa_supplicant
    openssh
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

7. Creamos un archivo `~/.config/nix/nix.conf`

```conf
experimental-features = nix-command flakes
```

8. Ahora si corremos el siguiente comando a la altura de nuestro `flake.nix`

```bash
NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix build --impure .#packages.aarch64-linux.sdcard
```

> [!NOTE]
> Hasta aqui he llegado porque mi micro sd se quedo sin espacio.

9. Ahora tenemos que cargar ese `.img` que se genero en nuestra micro sd e iniciar la raspberry pi

```bash
sudo -s
nix-channel --update
nixos-generate-config
nano /etc/nixos/configuration.nix
```

10. Modificamos la configuración de nix

    - Activamos el SSH
    - Definimos un usuario

11. Cambiamos la contraseña 

```bash
passwd USER_DEFINIDO
```

12. Rebuildeamos

```bash
nixos-rebuild switch
```

---

[video de donde se saco info](https://www.youtube.com/watch?v=VIuPRL6Ucgk&t=223s)

