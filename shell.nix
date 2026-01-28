{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    terraform
    azure-cli
    vault
    git
    jq
    kubectl
    nixd
  ];

}
