{
  description = "zig";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      my-packages = with pkgs; [
        zig
        zls
        gcc
      ];
    in {
      packages.${system}.default = pkgs.runCommand "my-zig-env-dummy" {
        buildInputs = my-packages;
        # 实际的构建指令可以为空，因为我们只关心依赖
      } "mkdir -p $out; touch $out/dummy-file";
      devShells.${system}.default = pkgs.mkShell {
        packages = my-packages;
      };
    };
}
