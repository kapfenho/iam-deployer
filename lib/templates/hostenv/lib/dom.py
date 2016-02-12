
import sys

# start domain, no server names given
#
def startDomain():
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
	acNmConnect();
	if 'AdminServer' in servers:
		nmStart('AdminServer');
		servers = servers - set(['AdminServer'])

	if len(servers) > 0:
		acConnect()
		for s in servers:
			try:
				start(name=s, type='Server', block='true');
			except:
				pass;

def stopDomain():
	acNmConnect();
	acConnect();
	for s in domManagedServers:
		try:
			shutdown(name=s, entityType="Server", force="true");
		except:
			pass;
	shutdown("AdminServer", entityType="Server", force="true");


def stopServers(servers):
	acNmConnect();
	acConnect();

	if "AdminServer" in severs:
		stopAdmin = True;
		servers = servers - set(["AdminServer"])

	for s in servers:
		try:
			shutdown(name=s, entityType="Server", force="true");
		except:
			pass;

	if stopAdmin == True:
		shutdown(name="AdminServer", entityType="Server", force="true");



def main(argv):
	pNum = len(argv)
	if len(argv) < 2:
		sys.stderr.write("Usage: %s {start|stop|kill|statuss} [server1 [server2 ...]]" % (argv[0],))
        return 1

	cmd = argv[1];
	if len(argv) > 3:
		servers = set(argv[2:])
	
	if cmd == "start":
		if servers:
			startServers(servers);
		else:
			startDomain();
	elif cmd == "stop":
		if servers:
			stopServers(servers);
		else:
			stopDomain();
	elif cmd == "kill":
		if servers:
			killServers(servers);
		else:
			killDomain();
	elif cmd == "status":
		printDomainStatus();






if __name__ == "__main__":
    sys.exit(main(sys.argv))

        
