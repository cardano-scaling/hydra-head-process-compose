{ inputs, ... }: {
  perSystem = { pkgs, system, ... }:
  {
    devShells = {
      default = pkgs.mkShell {
        buildInputs = with inputs; [
          hydra.packages."${system}".hydra-tui
          hydra.packages."${system}".hydra-node
          cardano-node.packages."${system}".cardano-node
          mithril.packages."${system}".mithril-client-cli
          cardano-node.packages."${system}".cardano-cli
        ];
      };
    };
  };
}
