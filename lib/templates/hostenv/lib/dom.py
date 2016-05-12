import sys

# start domain, no server names given
#
def startDomain(domClusters):
	if nm() == False:
		acNmConnect();
	try:
		nmStart("AdminServer");
	except:
		print "ERROR while starting AdminServer";
		exit();
	acConnect();
	try:
		for c in domClusters:
			start(name=c, type='Cluster', block="true");
	except:
		pass


# start servers in domain, list of server name come as parameters
#
def startServers(servers):
	if nm() == False:
		acNmConnect();
	if "AdminServer" in servers:
		nmStart("AdminServer");

	if len(servers) > 0:
		acConnect()
		for s in servers:
			try:
				if s != "AdminServer":
					start(name=s, type='Server', block='true');
			except:
				pass;


# start servers in domain, list of server name come as parameters
#
def nmStartServers(servers):
	if nm() == False:
		acNmConnect();
	for s in servers:
		try:
			nmStart(serverName=s);
		except:
			pass;


# stop whole domain, used when no parameters are set
#
def stopDomain(domServers):
	if nm() == False:
		acNmConnect();
	acConnect();
	for s in domServers:
		try:
			shutdown(name=s, entityType="Server", force="true");
		except:
			pass;
	shutdown(name="AdminServer", entityType="Server", force="true");


# kill stated servers
#
def killServers(servers):
	if nm() == False:
		acNmConnect();
	for s in servers:
		try:
			nmKill(serverName=s);
		except:
			pass;


# stop stated servers
#
def stopServers(servers):
	acNmConnect();
	admin = False;
	try:
		acConnect();
		admin = True;
	except:
		killServers(servers);

	if admin == True:
		for s in servers:
			try:
				if s != "AdminServer":
					shutdown(name=s, entityType="Server", force="true");
			except:
				pass;

		if "AdminServer" in servers:
			shutdown(name="AdminServer", entityType="Server", force="true");


def main(argv):

	nmPort = os.environ["NM_PORT"];
	domName  = os.environ["DOMAIN"];
	admDir = os.environ["ADMIN_HOME"];
	domDir = os.environ["WRK_HOME"];
	domAdminServer = os.environ["DOMAIN_ADMIN_SERVER"];
	domAdminPort = os.environ["DOMAIN_ADMIN_PORT"];
	domUrl = "t3://" + domAdminServer + ":" + domAdminPort;
	domUC = os.environ["DOMAIN_USER_CONFIG"];
	domUK = os.environ["DOMAIN_USER_KEY"];
	nmUC = os.environ["NM_USER_CONFIG"];
	nmUK = os.environ["NM_USER_KEY"];
	domClusters = os.environ["DOMAIN_CLUSTERS"].split(',');
	domServers = os.environ["DOMAIN_SERVERS"].split(',');

	if len(argv) < 2:
		sys.stderr.write("Usage: %s {start|stop|kill|status} [server1 [server2...]]\n" % (argv[0],))
		return 1;

	cmd = argv[1];
	servers = None;
	if len(argv) > 2:
		servers = argv[2:]

	if cmd == "start":
		if servers is None:
			startDomain(domClusters);
		else:
			startServers(servers);

	elif cmd == "nmstart":
		if servers is None:
			sys.stderr.write("ERROR: command nmstart needs servername")
		else:
			nmStartServers(servers);

	elif cmd == "stop":
		if servers is None:
			stopDomain(domServers);
		else:
			stopServers(servers);

	elif cmd == "kill":
		if servers is None:
			sys.stderr.write("ERROR: command kill needs servername")
		else:
			killServers(servers);

	elif cmd == "status":
		printDomainStatus();

# --- main ------------------------------------------------------------
#
main(sys.argv)

