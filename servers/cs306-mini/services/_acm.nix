{ config, lib, pkgs, ... }:

let
	sources = import <acm-aws/nix/sources.nix>;
in
{
	# List ACM at CSUF-specific services here.
	services.managed.services = with lib; {
		triggers = {
			command = getExe pkgs.triggers;
			environment = import <acm-aws/secrets/triggers-env.nix>;
		};

		pomo = {
			command = getExe pkgs.pomo;
			environment = import <acm-aws/secrets/pomo.nix>;
			serviceConfig.StartLimitInterval = "0"; # Permit unlimited restarts.
		};

		acm-nixie = {
			command = getExe pkgs.acm-nixie;
			environment = import <acm-aws/secrets/acm-nixie-env.nix>;
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
			environment = import <acm-aws/secrets/crying-counter-env.nix>;
		};

		discord-conversation-summary-bot = {
			command = getExe pkgs.discord_conversation_summary_bot;
			workingDirectory = pkgs.writeTextDir
				"config.json"
				(builtins.readFile <acm-aws/secrets/discord_conversation_summary_bot.json>);
		};

		discord-ical-srv = {
			command = [
				(getExe pkgs.discord-ical-srv)
				"-l" "unix:///run/discord-ical-srv/http.sock"
			];
			environment = import <acm-aws/secrets/discord-ical-srv-env.nix>;
		};

		discord-ical-reminder = {
			command = [
				(getExe pkgs.discord-ical-reminder)
				"-c"
				"${pkgs.writeText
					"discord-ical-reminder.json"
					(builtins.toJSON (import <acm-aws/secrets/ical-reminders.nix>))}"
			];
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
}
