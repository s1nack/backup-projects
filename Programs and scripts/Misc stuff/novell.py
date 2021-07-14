#!/usr/bin/python -u

import sys,string,commands

class NovellHelper:
	def __init__(self):
		self.stdin = sys.stdin
		self.stdout = sys.stdout

	def ldap_request(self,ip_client,infos_ip,infos_basedn,infos_binddn,infos_passwd):
		requete = list()
		requete.append("ldapsearch -LLL -h " + infos_ip + " -x -b '" + infos_basedn + "' -D '" + infos_binddn + "' -w '" + infos_passwd + "' '(&(objectclass=posixAccount)(ipHostNumber=" + ip_client + "))' uid")
		req_user = commands.getoutput(requete[0])
		req_user = req_user.split("\n")
		req_user = req_user[1].split(": ")
		req_user = req_user[1]
		return req_user
	
	def run(self):
		infos_ip = sys.argv[1]
		infos_basedn = sys.argv[2]
		infos_binddn = sys.argv[3]
		infos_passwd = sys.argv[4]
		line = self.stdin.readline()[:-1]
		while line:
			data = string.split(line)
			ip_client = data[0]
			username = self.ldap_request(ip_client,infos_ip,infos_basedn,infos_binddn,infos_passwd)
			self.stdout.writelines("OK user="+username+" log="+username+"\n")
			line = self.stdin.readline()[:-1]

if __name__ == "__main__":
	nv = NovellHelper()
	nv.run()
