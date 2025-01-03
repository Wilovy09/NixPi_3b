# Instalando NixOS en una Pi 3 B+

1. Instalamos el `.img` de Raspbian
    - Podemos usar `rpi-imager` o descargar directamente la [iso](https://www.raspberrypi.com/software/operating-systems/) que queremos.
    - Si decidimos descargarla nosotros mismos hay que seguir los siguientes pasos:
    - Descomprimir el `.img.xz` para obtener un `.img`

> [!NOTE]
> Recomiendo usar [ouch](https://github.com/ouch-org/ouch)

```bash
$> nix-shell -p ouch
$> ouch decompress NOMBRE_DE_LA_IMAGEN.img.xz
```
    
    - Esto nos generara un archivo `.img`
    - Ahora tenemos que cargarlo a nuestra micro sd, para eso usamos el comando y esperamos a que termine

```bash
$> sudo dd if=2024-11-19-raspios-bookworm-armhf.img of=/dev/sdb bs=4M status=progress
```

    - Ahora insertamos nuestra micro sd a nuestra Pi 3 B+

2. Conectarnos a internet.
3. Instalamos `nix-bin`

```bash
$> sudo apt install nix-bin
```

4. Creamos un archivo `flake.nix` con el siguiente contenido:

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

  outputs = { self, nixpkgs, nixos-generators, ... }:
  {
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
            extraGroups = [ "wheel" ];
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

5. Creamos otro archivo `extra-config.nix`

```nix
{ config, lib, pkgs, ... }:
{
  networking.firewall.enable = false;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
       openssh
  ];

  services.openssh.enable = true;
}
```
