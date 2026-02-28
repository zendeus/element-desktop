{
  description = "A Nix-flake-based Node Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: let
        isLinux = pkgs.stdenv.hostPlatform.isLinux;
        electronDeps = with pkgs; pkgs.lib.optionals isLinux [
          glib
          nss
          nspr
          dbus
          atk
          cups
          cairo
          gtk3
          pango
          xorg.libX11
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXrandr
          libgbm
          mesa
          expat
          xorg.libxcb
          libxkbcommon
          udev
          alsa-lib
          at-spi2-atk
        ];
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            node2nix
            nodejs
            pnpm
            yarn
          ];
          buildInputs = electronDeps;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath electronDeps;
        };
      });
    };
}
