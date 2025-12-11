{
  description = "hydra-head-two-peers";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    hydra-coding-standards.url = "github:cardano-scaling/hydra-coding-standards/0.7.1";
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    # Most relevant version
    hydra.url = "github:cardano-scaling/hydra/1.2.0";
    cardano-node.url = "github:IntersectMBO/cardano-node/10.5.3";
    mithril.url = "github:input-output-hk/mithril/2543.1-hotfix";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./nix);

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
      "https://cardano-scaling.cachix.org"
      "https://horizon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "cardano-scaling.cachix.org-1:QNK4nFrowZ/aIJMCBsE35m+O70fV6eewsBNdQnCSMKA="
      "horizon.cachix.org-1:MeEEDRhRZTgv/FFGCv3479/dmJDfJ82G6kfUDxMSAw0="
    ];
    allow-import-from-derivation = true;
  };
}
