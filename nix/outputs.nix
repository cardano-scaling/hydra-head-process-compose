{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }:
  let
    peers = ["raspi"];
    nodeId = "me";

    networkName = "preview";
    networkMagic = "2";
    mithrilDir = "testing-preview";

    # Customise to your network
    hydraPort = "5005";
    publicIp = "10.0.0.42";
    nodeVersion = "10.5.3";
  in {
    process-compose."default" = {
      package = pkgs.process-compose;
      settings.log_location = "run/logs/process-compose.log";
      settings.log_level = "debug";
      settings.processes = {

        # Cardano node
        cardano-node = {
          working_dir = "./run";
          depends_on.maybe-mithril.condition = "process_completed";
          availability.restart = "on_failure";
          ready_log_line = "NodeIsLeader";
          command = pkgs.writeShellApplication {
            name = "cardano-node";
            text = ''
              if [ ! -d config ]; then
                mkdir config
                cd config

                curl -L -O \
                  https://github.com/IntersectMBO/cardano-node/releases/download/${nodeVersion}/cardano-node-${nodeVersion}-linux.tar.gz

                tar xf cardano-node-${nodeVersion}-linux.tar.gz \
                    ./share/${networkName} \
                    --strip-components=3
              fi

              ${pkgs.lib.getExe inputs.cardano-node.packages.${system}.cardano-node} \
                run \
                  --config config/config.json \
                  --topology config/topology.json \
                  --database-path db \
                  --socket-path node.socket
            '';
          };
        };


        # (Maybe) Mithril
        maybe-mithril = {
          working_dir = "./run";
          command = pkgs.writeShellApplication {
            name = "maybe-mithril";
            text = ''
              if [ ! -d db ]; then
                export AGGREGATOR_ENDPOINT=https://aggregator.${mithrilDir}.api.mithril.network/aggregator

                GENESIS_VERIFICATION_KEY=''$(curl https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/${mithrilDir}/genesis.vkey 2> /dev/null)
                export GENESIS_VERIFICATION_KEY

                ANCILLARY_VERIFICATION_KEY=''$(curl https://raw.githubusercontent.com/input-output-hk/mithril/main/mithril-infra/configuration/${mithrilDir}/ancillary.vkey 2> /dev/null)
                export ANCILLARY_VERIFICATION_KEY

                ${inputs.mithril.packages.${system}.mithril-client-cli}/bin/mithril-client \
                  cardano-db download latest
              fi
            '';
          };
        };


        # Hydra node
        hydra-node = {
          depends_on.cardano-node.condition = "process_started";
          working_dir = "./run";
          availability.restart = "on_failure";
          command = pkgs.writeShellApplication {
            name = "hydra-node";
            text =
              let
                peerArgs =
                  let
                    dir = "../peers";
                    f = name: pkgs.lib.strings.concatStringsSep " "
                      [
                        "--peer \"$(cat ${dir}/${name}/peer)\""
                        "--hydra-verification-key \"${dir}/${name}/hydra.vk\""
                        "--cardano-verification-key \"${dir}/${name}/fuel.vk\""
                      ];
                  in
                  pkgs.lib.strings.concatMapStringsSep " " f peers;
              in
              ''
                ${pkgs.hydra-node}/bin/hydra-node \
                  --cardano-signing-key ../credentials/fuel.sk \
                  --hydra-signing-key ../credentials/hydra.sk \
                  --node-id ${nodeId} \
                  --api-host 0.0.0.0 \
                  --listen 0.0.0.0:${hydraPort} \
                  --advertise ${publicIp}:${hydraPort} \
                  --network ${networkName} \
                  --testnet-magic ${networkMagic}  \
                  --node-socket node.socket \
                  --persistence-dir persistence \
                  --ledger-protocol-parameters ../peers/protocol-parameters.json \
                  --contestation-period 300s \
                  --deposit-period 300s \
                  --monitoring-port 9009 \
                  --persistence-rotate-after 10000 \
                  ${peerArgs}
              '';
          };
        };


        # Hydra TUI
        hydra-tui = {
          is_foreground = true;
          command = pkgs.writeShellApplication {
            name = "hydra-tui";
            text = ''
              ${pkgs.hydra-tui}/bin/hydra-tui \
                --connect 0.0.0.0:4001 \
                --node-socket run/node.socket \
                --testnet-magic ${networkMagic} \
                --cardano-signing-key credentials/funds.sk
              '';
            };
          };
      };
    };
  };
}
