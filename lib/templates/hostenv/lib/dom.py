import sys

# start domain, no server names given
#
def startDomain(domClusters):
	acNmConnect();
	try:
		nmStart(domAdminServer);
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
	acNmConnect();
	if domAdminServer in servers:
		nmStart(domAdminServer);
		servers.remove(domAdminServer);

	if len(servers) > 0:
		acConnect()
		for s in servers:
			try:
				start(name=s, type='Server', block='true');
			except:
				pass;


# stop whole domain, used when no parameters are set
#
def stopDomain(domServers):
	acNmConnect();
	acConnect();
	for s in domServers:
		try:
			shutdown(name=s, entityType="Server", force="true");
		except:
			pass;
	shutdown(domAdminServer, entityType="Server", force="true");


# stop stated servers
#
def stopServers(servers):
	acNmConnect();
	acConnect();

	if domAdminServer in servers:
		stopAdmin = True;
		servers.remove(domAdminServer);

	for s in servers:
		try:
			shutdown(name=s, entityType="Server", force="true");
		except:
			pass;

	if stopAdmin == True:
		shutdown(name=domAdminServer, entityType="Server", force="true");



def main(argv):

	dClusters = domClusters.split(',');
	dServers = domServers.split(',');

	if len(argv) < 2:
		sys.stderr.write("Usage: %s {start|stop|kill|statuss} [server1 [server2...]]\n" % (argv[0],))
		return 1;

	cmd = argv[1];
	servers = None;
	if len(argv) > 2:
		servers = argv[2:]
	
	if cmd == "start":
		if servers is None:
			startDomain(dClusters);
		else:
			startServers(servers);

	elif cmd == "stop":
		if servers is None:
			stopDomain(dServers);
		else:
			stopServers(servers);

	elif cmd == "kill":
		if servers is None:
			killDomain();
		else:
			killServers(servers);

	elif cmd == "status":
		printDomainStatus();

# --- main ------------------------------------------------------------
#
main(sys.argv)

