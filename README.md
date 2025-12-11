# Hydra Head via process-compose

This is a simple configuration of a process-compose based Hydra Head setup,
where one peer is local (running on the computer you execute this on) and
the other peers are configured through files in this folder.

This is a companion repo to: <https://github.com/cardano-scaling/hydra-blockfrost-rpi-demo>

This repo configures the head on the preview network; and optionally with
Mithril, if there is no `db` folder present.


### Usage

Put peer information in `./peers`:

```shell
> tree peers
peers
├── protocol-parameters.json
└── raspi
    ├── fuel.vk
    ├── hydra.vk
    └── peer

2 directories, 4 file
```

Your credentials are expected to be provided in `../credentials`:

- `fuel.sk` - to pay for L1 transactions
- `funds.sk` - to bring L1 funds into the Head
- `hydra.sk` - to sign hydra transactions

Other bits of information need to be configured in `outputs.nix`;

```nix
...
    # Customise to your network
    hydraPort = "5005";
    publicIp = "10.0.0.42";
    nodeVersion = "10.5.3";
```

### Running

```shell
nix run . -- --theme "Catppuccin Latte"
```


### Trivia

Key-generation commands:

```shell
nix run github:IntersectMBO/cardano-node/10.5.3#cardano-cli \
      -- address key-gen \
      --verification-key-file funds.vk \
      --signing-key-file funds.sk


nix run github:IntersectMBO/cardano-node/10.5.3#cardano-cli \
      -- address key-gen \
      --verification-key-file fuel.vk \
      --signing-key-file fuel.sk

nix run github:cardano-scaling/hydra/1.2.0#hydra-node \
      -- gen-hydra-key \
      --output-file hydra
```
