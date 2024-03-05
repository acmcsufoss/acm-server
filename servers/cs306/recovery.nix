{ config, lib, pkgs, ... }:

{
	# Enable watchdog for resiliency.
	boot.kernel.sysctl = {
		"kernel.hardlockup_panic" = 1;  
		"kernel.panic" = 1; 
		"kernel.nmi_watchdog" = 1; 
		"kernel.watchdog_thresh" = 10;
	};

	# Enable HTTP healthchecking, rebooting on failure.
	services.healthcheck.httpEndpoint = "cs306.acmcsuf.com";
}
