{
  description = "Kernel build environment for Xiaomi SDM845 devices";

  inputs = {
    # GCC version is determined by the nixpkgs revision pinned in flake.lock.
    # Run `nix flake update` to bump to the latest nixpkgs (and thus latest GCC).
    # To pin a specific revision: nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/<rev>
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Use unwrapped cross-compilers. The Nix cc-wrapper injects
      # -isystem, -L, -z relro, -rpath etc. via NIX_CFLAGS_COMPILE and
      # NIX_LDFLAGS, which break kernel cross-compilation. Unwrapped
      # binaries behave like a plain cross-toolchain.
      aarch64Cc = pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc;
      armEmbeddedCc = pkgs.pkgsCross.arm-embedded.stdenv.cc;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          # Host build tools (wrapped is fine)
          pkgs.gnumake
          pkgs.bc
          pkgs.perl
          pkgs.flex
          pkgs.bison
          pkgs.openssl.dev
          pkgs.elfutils
          pkgs.ncurses.dev
          pkgs.pkg-config
        ];

        shellHook = ''
          # Prepend unwrapped cross-compiler bins to PATH
          export PATH="${aarch64Cc.cc}/bin:${aarch64Cc.bintools.bintools}/bin:${armEmbeddedCc.cc}/bin:${armEmbeddedCc.bintools.bintools}/bin:$PATH"
          export CROSS_COMPILE=${aarch64Cc.targetPrefix}
          export CROSS_COMPILE_ARM32=${armEmbeddedCc.targetPrefix}
        '';
      };
    };
}
