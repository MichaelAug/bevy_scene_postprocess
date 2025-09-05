{
  description = "Bevy Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
          extensions = [ "rust-src" "rust-analyzer" "clippy" ];
        });
      in
      {
        devShells.default =
          with pkgs;
          mkShell rec {
            buildInputs = [
              # Rust
              rustToolchain

              # Bevy dependencies
              alsa-lib
              udev
              vulkan-loader
              pkg-config

              # X11 dependencies
              xorg.libX11
              xorg.libXcursor
              xorg.libXi
              xorg.libXrandr

              # Wayland dependencies
              libxkbcommon
              wayland
            ];

            nativeBuildInputs = with pkgs; [ pkg-config ];

            # Include dependencies in LD_LIBRARY_PATH
            # So Bevy can find them
            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          };
      }
    );
}
