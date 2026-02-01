{ inputs, ... }:
let
  system = "x86_64-linux";
in
{
  environment.systemPackages = [
    inputs.bpf.packages.${system}.burpsuitepro
    inputs.ipoc.packages.${system}.idapro
  ];
}
