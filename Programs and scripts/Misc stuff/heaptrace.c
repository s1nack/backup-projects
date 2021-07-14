#include <stdio.h>
#include <string.h>

static int parse_env(char** myenvp) 
{
	int i;
	while(myenvp[i]!=0) {
		i++;
	}
	return i;
}

static int call_process(char* cible, char** envp) {
	execve(cible, 0, envp);
	return 1;
}

static int parseopt(int argc, char** argv, char** envp) {
	if((argc<2) || (argc>2)) {
		printf("usage: %s cible\n",argv[0]);
		return 0;
	}
	if(envp==0) {
		printf("Erreur lors de la récupération de l'environnement\n");
		return 0;			
	}
	return 1;
}

static int hook_and_run(char* cible, char** envp) {
	int nb_env = parse_env(envp);
	envp[nb_env] = "LD_PRELOAD=./malloc.so";
	envp[nb_env+1] = 0;	

	int c = call_process(cible, envp);
	if(c==0) {
		printf("Erreur lors de l'exécution de la cible %s\n", cible);
		return 0;
	} else {
	return 1;
	}
}

int main(int argc, char **argv, char **envp)
{
	int rec = parseopt(argc, argv, envp);
	if(rec==0)
		return 0;

	int is_hooked = hook_and_run(argv[1], envp);
	if(is_hooked==0) {
		printf("Erreur lors du hook\n");
		return 0;
	}		
	
//	char* cible = argv[1];
//      char **myenvp = envp;
//	int r = parse_env(envp);
//	
//	myenvp[r] = "LD_PRELOAD=./malloc.so";
//	myenvp[r+1] = 0;
//	int r2 = parse_env(myenvp);
//	int c = call_process(cible,myenvp);
//	if(c != 1) 
//		printf("call_process bug\n");	
//	
        return 0;
}

