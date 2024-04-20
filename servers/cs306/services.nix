{ config, lib, pkgs, self, sources, ... }:

{
	services.managed.enable = true;

	services.managed.services = with lib; {
		triggers = {
			command = getExe pkgs.triggers;
			environment = import (self + "/secrets/triggers-env.nix");
		};

		pomo = {
			command = getExe pkgs.pomo;
			environment = import (self + "/secrets/pomo.nix");
			serviceConfig.StartLimitInterval = "0"; # Permit unlimited restarts.
		};

		acm-nixie = {
			command = getExe pkgs.acm-nixie;
			environment = import (self + "/secrets/acm-nixie-env.nix");
		};

		crying-counter = {
			# Deal with this thing not having a config flag for some weird reason.
			# The database path is both hard-coded and relies on the existing database from the source
			# repository. This is a terrible way to handle things, but it's what we have to work with.
			script = ''
				DATABASE_PATH="crying_counter/db/counts.sqlite"
				mkdir -p $(dirname $DATABASE_PATH)

				# If the database doesn't exist, copy it from the source repository.
				if [[ ! -f $DATABASE_PATH ]]; then
					cp --no-preserve=mode,ownership ${sources.crying-counter}/$DATABASE_PATH $DATABASE_PATH
					chmod 600 $DATABASE_PATH
				fi

				${getExe pkgs.crying-counter}
			'';
			environment = import (self + "/secrets/crying-counter-env.nix");
		};

		discord-conversation-summary-bot = {
			command = getExe pkgs.discord_conversation_summary_bot;
			workingDirectory = pkgs.writeTextDir
				"config.json"
				(builtins.readFile (self + "/secrets/discord_conversation_summary_bot.json"));
		};

		discord-ical-srv = {
			command = [
				(getExe pkgs.discord-ical-srv)
				"-l" "unix:///run/discord-ical-srv/http.sock"
			];
			environment = import (self + "/secrets/discord-ical-srv-env.nix");
		};

		discord-ical-reminder = {
			command = [
				(getExe pkgs.discord-ical-reminder)
				"-c"
				"${pkgs.writeText
					"discord-ical-reminder.json"
					(builtins.toJSON (import (self + "/secrets/ical-reminders.nix")))}"
			];
		};

		go-workshop =
			let
				shell = import "${sources.go-workshop}/shell.nix" { inherit pkgs; };
				present = shell.present;
			in
			{
				command = [ (getExe present) "--use_playground" "--http=127.0.0.1:38572" ];
				workingDirectory = sources.go-workshop;
			};

		quizler = {
			command = getExe pkgs.quizler;
			environment.QUIZLER_PORT = "37867";
			serviceConfig = {
				# Use strict resource controls since this is an exposed and untrusted
				# service.
				ProtectSystem = "strict";
				ProtectHome = true;
				PrivateDevices = true;
				MemoryMax = "256M";
				TasksMax = 128;
				CPUQuota = "50%";
				RestrictNetworkInterfaces = "lo"; # enough for localhost
			};
		};
	};

	services.christmasd-test = {
		enable = true;
		ledPointsFile = builtins.fetchurl
			"https://gist.githubusercontent.com/diamondburned/1d9a83347e153686ca192c6f5baf0b79/raw/63b06ed82fd858bdb8b15a5971df92dd4bab40c3/led-points.csv";
		extraFlags = {
			http-addr = "unix://$RUNTIME_DIRECTORY/http.sock";
		};
	};

	systemd.services.sendlimiter =
		let
			extraArgs = [];
			secrets = import (self + "/secrets/sendlimiter.nix");
			args = lib.concatStringsSep
				" "
				(map lib.escapeShellArg (extraArgs ++ secrets.channelIDs));
		in {
			enable = true;
			description = "Send limiter Discord bot";
			after = [ "network-online.target" ];
			wantedBy = [ "multi-user.target" ];
			environment = {
				BOT_TOKEN = secrets.botToken;
			};
			serviceConfig = {
				Type = "simple";
				ExecStart = "${pkgs.sendlimiter}/bin/sendlimiter ${args}";
				Restart = "on-failure";
				RestartSec = "1s";
			};
		};

	services.dischord = {
		enable = true;
		config = builtins.readFile (self + "/secrets/dischord-config.toml");
	};
}
