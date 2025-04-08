{
  config,
  lib,
  pkgs,
  ...
}:

let
  self = config.services.healthcheck;
  enable = checkScript != "";

  checkScript =
    with lib;
    ("set -eo pipefail")
    + (optionalString (self.checkUsers) ''
      loggedInUsers=$(users)
      if [[ "$loggedInUsers" != "" ]]; then
        echo "Users are logged in, not running healthcheck" >&2
        echo "Logged in users: $loggedInUsers" >&2
        exit 0
      fi
    '')
    + (optionalString (self.httpEndpoint != null) ''
      ${../../scripts}/healthcheck-http ${self.httpEndpoint}
    '');

  checkDeps =
    (with pkgs; [
      bash
      coreutils
    ])
    ++ (if self.httpEndpoint != null then with pkgs; [ curl ] else [ ]);
in

{
  options.services.healthcheck = with lib; {
    httpEndpoint = mkOption {
      default = null;
      example = "google.com";
      type = types.nullOr types.str;
      description = "The HTTP endpoint to check";
    };

    calendar = mkOption {
      default = "*:30:00";
      type = types.str;
      description = "The calendar to run the healthcheck, defaults to every 30 minutes";
    };

    checkUsers = mkOption {
      default = true;
      type = types.bool;
      description = "Whether the check should only run when no users are logged in";
    };
  };

  config = lib.mkIf enable {
    systemd.services.healthcheck = {
      description = "Healthcheck for the server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        # Retry every 30 seconds if the check fails.
        Restart = "on-failure";
        RestartSec = 30;
        # Permit 10 restarts in 10 minutes.
        StartLimitBurst = 10;
        StartLimitIntervalSec = 10 * 60;
        # If the check fails all 5 times within 10 minutes, reboot the system.
        StartLimitAction = "reboot-force";
      };
      script = checkScript;
      path = checkDeps;
    };

    systemd.timers.healthcheck = {
      description = "Timer for the healthcheck";
      wantedBy = [ "timers.target" ];
      after = [ "network.target" ];
      timerConfig = {
        OnCalendar = self.calendar;
        Persistent = true;
      };
    };
  };
}
