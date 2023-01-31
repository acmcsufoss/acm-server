{ jre_minimal }:

jre_minimal.override {
	# jdk.jpackage will link all of OpenJDK!
	modules = [
		"java.base"
		"java.compiler"
		"java.datatransfer"
		"java.desktop"
		"java.instrument"
		"java.logging"
		"java.management"
		"java.management.rmi"
		"java.naming"
		"java.net.http"
		"java.prefs"
		"java.rmi"
		"java.scripting"
		"java.se"
		"java.security.jgss"
		"java.security.sasl"
		"java.smartcardio"
		"java.sql"
		"java.sql.rowset"
		"java.transaction.xa"
		"java.xml"
		"java.xml.crypto"
		"jdk.accessibility"
		"jdk.attach"
		"jdk.charsets"
		"jdk.compiler"
		"jdk.crypto.cryptoki"
		"jdk.crypto.ec"
		"jdk.dynalink"
		"jdk.editpad"
		"jdk.hotspot.agent"
		"jdk.httpserver"
		"jdk.incubator.foreign"
		"jdk.incubator.vector"
		"jdk.internal.ed"
		"jdk.internal.jvmstat"
		"jdk.internal.le"
		"jdk.internal.opt"
		"jdk.internal.vm.ci"
		"jdk.internal.vm.compiler"
		"jdk.internal.vm.compiler.management"
		"jdk.jartool"
		"jdk.javadoc"
		"jdk.jcmd"
		"jdk.jconsole"
		"jdk.jdeps"
		"jdk.jdi"
		"jdk.jdwp.agent"
		"jdk.jfr"
		"jdk.jlink"
		"jdk.jshell"
		"jdk.jsobject"
		"jdk.jstatd"
		"jdk.localedata"
		"jdk.management"
		"jdk.management.agent"
		"jdk.management.jfr"
		"jdk.naming.dns"
		"jdk.naming.rmi"
		"jdk.net"
		"jdk.nio.mapmode"
		"jdk.random"
		"jdk.sctp"
		"jdk.security.auth"
		"jdk.security.jgss"
		"jdk.unsupported"
		"jdk.unsupported.desktop"
		"jdk.xml.dom"
		"jdk.zipfs"
	];
}