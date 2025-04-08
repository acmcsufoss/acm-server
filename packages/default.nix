{ pkgs, inputs }:

let
  inherit (inputs) self;

  callPackage = pkgs.lib.callPackageWith (
    pkgs
    // {
      inherit inputs;
      nivInputs = self.lib.nivInputs pkgs;
    }
  );
in

{
  jre_small = callPackage ./jre-small { };
  sshwifty = callPackage ./sshwifty { };
  quizler = callPackage ./quizler { };

  # Go
  acmregister = callPackage ./acmregister { };
  acm-nixie = callPackage ./acm-nixie { };
  caddy = callPackage ./caddy { };
  sendlimiter = callPackage ./sendlimiter { };
  sysmet = callPackage ./sysmet { };
  dischord = callPackage ./dischord { };
  discord-ical-reminder = callPackage ./discord-ical-reminder { };
  discord-ical-srv = callPackage ./discord-ical-srv { };
  discord_conversation_summary_bot = callPackage ./discord_conversation_summary_bot { };
  christmasd = callPackage ./christmasd { };
  fullyhacks-qrms = callPackage ./fullyhacks-qrms { };

  # Java
  triggers = callPackage ./triggers { };

  # Deno
  pomo = callPackage ./pomo { };

  # Python
  crying-counter = callPackage ./crying-counter { };
}
