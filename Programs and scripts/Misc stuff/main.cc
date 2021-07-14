#include <time.h>
#include <unistd.h>
#include <assert.h>
#include "global.h"
#include "macros.h"
#include "redactedLog.h"
#include "ODirectory.h"
#include "libconf.h"
#include "libmisc.h"
#include "RequestInfo.h"
#include "libconfig.h"
#include "ProcessFilterLdap.h"
#include "redactedLDAP.h"
#include "redactedCacheUser.h"

typedef struct ODirectoryList {
        GList                   *ldirectory;
        GHashTable      *hdirectory;
} ODirectoryList;

static ODirectoryList* get_directory_list(void) {
        ODirectoryList* list = g_new0(ODirectoryList, 1);
        list->hdirectory = g_hash_table_new(g_str_hash, g_str_equal);
        POOL_MYSQL(mysql);
        if (mysql->vquery("select di_type, di_lib from directory where di_active = 1")) {
                while(char **row = mysql->fetch()) {
                        ODirectory *dir = ODirectory::getDirectory(row[0], row[1]);
                        if (dir) {
                                redacted_log_info("Charge [%s]", row[1]);
                                list->ldirectory = g_list_insert(list->ldirectory, dir, 0);
                                g_hash_table_replace(list->hdirectory, g_strdup(row[1]), dir);
                        } else {
                                redacted_log_error("Ne peut créer %s %s", row[0], row[1]);
                        }
                }
        } else {
                redacted_log_error("Erreur pour recupérer la liste d'annuaire");
        }
        mysql->reset();
        mysql->release();
        return list;
}

GString *checkUserName(ODirectoryList *list, char *ip, char *name, char *filter, char *attr) {
	GString*    ok = g_string_new("");
	POOL_MYSQL_PRIVATE(mysql);
	char *type = mysql->vquery_value("select di_type from directory where di_lib = '%s'", name);
	ODirectory *d = NULL;
	GList *cur = list->ldirectory;
	d = (ODirectory*)cur->data;
	d = ODirectory::getDirectory(type, name);

	LDAPMessage *res = d->ldap->searchFilter(filter, ip);
	if (res) {
		LDAPMessage *entry = ldap_first_entry(d->ldap->ld, res);
		if (entry) {
			ok->str = d->ldap->getAttributeAsString(entry, attr);
		} 
	}

	ldap_msgfree(res);
	g_free(type);
	return ok;
}

GString *process_line(ODirectoryList *list, GString *line) {
	GString*    ok = g_string_new("");
        char *myline    = g_strdup(line->str);
        char *ip = g_strchomp(myline);
	char *filter = conf_get_key("auth_ldap_filter");
	char *attr = conf_get_key("auth_ldap_attr");
        char *name = conf_get_key("auth_ldap_lib");

	ok = checkUserName(list, ip, name, filter, attr);
        
	g_free(myline);
	g_free(ip);
	g_free(filter);
	g_free(attr);
	g_free(name);
        return ok;
}

int process(ODirectoryList *list) {
        GIOChannel* squid_in_channel = g_io_channel_unix_new(0);
        GIOChannel* squid_out_channel = g_io_channel_unix_new(1);
        GError*     error = NULL;
        GString*    line = g_string_new("");
        GIOStatus   squid_status;
        gsize                           s; /* size */
	GString* ok = g_string_new("");
	GString* login = g_string_new("");
        g_io_channel_set_encoding(squid_in_channel, NULL, &error);

        while (1) {
                squid_status = g_io_channel_read_line_string(squid_in_channel, line, NULL, &error);

                switch(squid_status) {
                        case G_IO_STATUS_NORMAL:
                                ok = process_line(list, line);
                                if (ok->str) {
					g_string_printf(login, "OK user=%s log=%s\n", ok->str, ok->str);
                                        g_io_channel_write_chars(squid_out_channel, login->str, -1, &s, &error);
				}
                                else
                                        g_io_channel_write_chars(squid_out_channel, "ERR\n", -1, &s, &error);
                                g_io_channel_flush(squid_out_channel, &error);
                                break;
                        case G_IO_STATUS_EOF:
                                redacted_log_info("Demande de fin -> arret");
                                return true;
                        default:
                                redacted_log_error("Erreur interne %s:%d", __FILE__, __LINE__);
                                abort();
                }
        }
}


int     main(int argc, char *argv[]) {
        if ( ! init_easy()) {
                printf("Erreur d'initialisation\n");
                return 1;
        }
        ODirectoryList *list = get_directory_list();
        process(list);
}

