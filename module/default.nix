# NixOS module for GrapheneOS AttestationServer
#
# Runs the attestation server as a systemd service with
# configurable domain, port, and email alerting.
#
# Usage:
#   services.grapheneos-attestation = {
#     enable = true;
#     domain = "attestation.example.com";
#     port = 8085;
#     emailAlerts = true;
#   };
{ lib, config, pkgs, ... }:
with lib; let
  cfg = config.services.grapheneos-attestation;
in {
  options.services.grapheneos-attestation = {
    enable = mkEnableOption "GrapheneOS AttestationServer";

    domain = mkOption {
      type = types.str;
      default = "localhost";
      description = "Domain name for the attestation server";
    };

    port = mkOption {
      type = types.port;
      default = 8085;
      description = "HTTP port for the attestation server";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/grapheneos-attestation";
      description = "Data directory for attestation database";
    };

    emailAlerts = mkOption {
      type = types.bool;
      default = false;
      description = "Enable email alerts for attestation failures";
    };

    javaPackage = mkOption {
      type = types.package;
      default = pkgs.jdk17;
      description = "Java runtime for the attestation server";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.grapheneos-attestation = {
      description = "GrapheneOS AttestationServer";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "grapheneos-attestation";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.javaPackage}/bin/java -jar ${cfg.dataDir}/attestation-server.jar";
        Restart = "on-failure";
        RestartSec = 10;

        # Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ReadWritePaths = [ cfg.dataDir ];
      };

      environment = {
        ATTESTATION_DOMAIN = cfg.domain;
        ATTESTATION_PORT = toString cfg.port;
        ATTESTATION_EMAIL_ALERTS = if cfg.emailAlerts then "true" else "false";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf (cfg.port != 0) [ cfg.port ];
  };
}
