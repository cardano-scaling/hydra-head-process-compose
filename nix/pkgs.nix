{ inputs, ... }: {
  perSystem = { config, system, compiler, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          (_final: _prev: {
            cabal-install = pkgs.haskell-nix.tool compiler "cabal-install" "3.10.3.0";
            cabal-fmt = config.treefmt.programs.cabal-fmt.package;
            haskell-language-server = pkgs.haskell-nix.tool compiler "haskell-language-server" "2.11.0.0";
            weeder = pkgs.haskell-nix.tool compiler "weeder" "2.9.0";
            inherit (inputs.cardano-node.packages.${system}) cardano-cli;
            inherit (inputs.cardano-node.packages.${system}) cardano-node;
            inherit (inputs.hydra.packages.${system}) hydra-node;
            inherit (inputs.hydra.packages.${system}) hydra-tui;
          })
        ];
      };
    in
    {
      _module.args = { inherit pkgs; };
    };

}
