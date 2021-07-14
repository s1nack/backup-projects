#include <windows.h>
#include <winnt.h>
#include <stdio.h>
#include <wchar.h>

#define PE_SIGNATURE 0x4550
//#define DEBUG 1

int RVAToOffset (DWORD RVA, PIMAGE_SECTION_HEADER sHeader);
unsigned char checkMSB(ULONG checked_var);
int parseDir(PIMAGE_RESOURCE_DIRECTORY pDirEntry);
void parseRes(PIMAGE_RESOURCE_DIRECTORY_ENTRY pResEntry);
void resIsData(PIMAGE_RESOURCE_DIRECTORY_ENTRY pResEntry);
int parsePE (char *exePath);
void addRes(char* exePath);
int getResSize(char* resPath);
void usage(char* name);

PIMAGE_RESOURCE_DIRECTORY pDirEntry;
PIMAGE_RESOURCE_DIRECTORY baseResDirectory;
PIMAGE_RESOURCE_DIRECTORY_ENTRY pResEntry;
PIMAGE_RESOURCE_DATA_ENTRY dataEntry;
PIMAGE_RESOURCE_DIRECTORY old_dir[20];
PIMAGE_RESOURCE_DIR_STRING_U sEntry;

LONG offFile;
unsigned char msb = 0;
int ret, totalEntries, m, count, old_count[20], old_total[20], resSize;
HANDLE hFile, hFileMapping, pFile;
BOOL isLoaded, isUpdated;
LPVOID lpFileBase;
USHORT nbentries;
LONG tOffset;
char* resPath;

int RVAToOffset (DWORD RVA, PIMAGE_SECTION_HEADER sHeader)
{
	int tRVA = 0;
	int t2RVA = 0;
	tRVA = (int) (RVA - sHeader->VirtualAddress);
	t2RVA = (int) (tRVA + sHeader->PointerToRawData);
	return t2RVA;
}

void addRes(char* exePath, char* resPath, LPCSTR resName)
{
	resSize = getResSize(resPath);
	pFile = BeginUpdateResource(exePath, FALSE);
	if (pFile == NULL) {
		printf("Error while opening file for updating resources: BeginUpdateResource\n");
		return;
	}
	isLoaded = UpdateResource(pFile,RT_BITMAP,resName,LANG_SYSTEM_DEFAULT,resPath,resSize);
	if (isLoaded == FALSE) {
		printf("Error while updating resources: UpdateResource\n");
		return;
	}
	isUpdated = EndUpdateResource(pFile, FALSE);
	if (isUpdated == FALSE) {
		printf("Error while updating resources: EndUpdateResource\n");
		return;
	}
	printf("res %s added. size= %i\n", resName, resSize);
	return;
}

void check_add()
{
	const char* path = ("E:\\marc.exe");
	const char* res1 = "myres1";
	const char* res2 = "myres2";
	char * name1 = "na";
	char * name2 = "nb";

	HANDLE hUpdate = BeginUpdateResource(path, FALSE);
	UpdateResource(hUpdate, RT_RCDATA, (LPCSTR)name1, 0, (void*)res1, strlen(res1) + 1);
	EndUpdateResource(hUpdate, FALSE);
	hUpdate = BeginUpdateResource(path, FALSE);
	UpdateResource(hUpdate, RT_RCDATA, (LPCSTR)name2, 0, (void*)res2, strlen(res2) + 1);
	EndUpdateResource(hUpdate, FALSE);
    return;
}

int getResSize(char* resPath)
{
	int size=0;
	WIN32_FILE_ATTRIBUTE_DATA attr;

	if( GetFileAttributesEx(resPath, GetFileExInfoStandard, &attr) == 0) 
	{
		printf("Error while seeking for %s size\n", resPath);
		return 0;
	}
	return attr.nFileSizeLow;
}

int parseDir(PIMAGE_RESOURCE_DIRECTORY pDirEntry)
{
	totalEntries = pDirEntry->NumberOfIdEntries + pDirEntry->NumberOfNamedEntries;
	old_count[m] = count;
	old_total[m] = totalEntries;
	old_dir[m] = pDirEntry;
	m++;
	for(count=0;count<totalEntries;count++)
	{
		old_count[m] = count;
		old_total[m] = totalEntries;
		old_dir[m] = pDirEntry;
		m++;
		pResEntry = (PIMAGE_RESOURCE_DIRECTORY_ENTRY) ((char*)pDirEntry + sizeof(IMAGE_RESOURCE_DIRECTORY) + (count*sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY)));
		parseRes(pResEntry);
		m--;
		count = old_count[m];
		totalEntries = old_total[m];
		pDirEntry = old_dir[m];
	}
	m--;
	count = old_count[m];
	totalEntries = old_total[m];
	pDirEntry = old_dir[m];
	return 0;
}

void parseRes(PIMAGE_RESOURCE_DIRECTORY_ENTRY pResEntry)
{
	int p = 0;

	tOffset = pResEntry->Name;
	msb = checkMSB(tOffset);
	if (msb == 1) 
	{
		sEntry = (PIMAGE_RESOURCE_DIR_STRING_U)((char*)lpFileBase + offFile + (tOffset ^ 0x80000000));
		printf("Lenght: %i\n", sEntry->Length);
		wprintf(L"Name: %s\n", sEntry->NameString);
	}

	tOffset = pResEntry->OffsetToData;
	msb = checkMSB(tOffset);
	if (msb == 0) {
		resIsData(pResEntry);
		return;
	}
	else {
		pDirEntry = (PIMAGE_RESOURCE_DIRECTORY) ((char*)lpFileBase + offFile + (tOffset ^ 0x80000000));
		p = parseDir(pDirEntry);
	}
	return;
}

void resIsData(PIMAGE_RESOURCE_DIRECTORY_ENTRY pResEntry)
{
	dataEntry = (PIMAGE_RESOURCE_DATA_ENTRY) ((char*)lpFileBase + offFile + pResEntry->OffsetToData);
	return;
}

unsigned char checkMSB(ULONG checked_var)
{
	unsigned char flag = 0;
	if (checked_var & 0x80000000)
		flag = 1;
	else
		flag = 0;
	return flag;
}



int parsePE (char *exePath) 
{
	PIMAGE_DOS_HEADER dosHeader;
	PIMAGE_NT_HEADERS peHeader;
	PIMAGE_FILE_HEADER fileHeader;
	PIMAGE_OPTIONAL_HEADER optHeader;
	PIMAGE_SECTION_HEADER secHeader;
	PIMAGE_DATA_DIRECTORY datDirectory;
	PIMAGE_RESOURCE_DIRECTORY resDirectory;
	LONG peOffset;
	ULONG resRVA;
	USHORT nSections = 0;
	int i=0, p=0;

	hFile = CreateFile(exePath, GENERIC_READ|GENERIC_WRITE,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
	if ( hFile == INVALID_HANDLE_VALUE )
	{
		printf("Error while opening file\n");
		return 1;
	}

	hFileMapping = CreateFileMapping(hFile,NULL,PAGE_READWRITE,0,0,NULL);
	if ( hFileMapping == 0 )
	{
		printf("Error while creating file mapping\n");
		return 1;
	}

	lpFileBase = MapViewOfFile(hFileMapping,FILE_MAP_WRITE,0,0,0);
	if ( lpFileBase == 0 )
	{
		printf("Error while mapping file\n");
		return 1;
	}

	dosHeader = (PIMAGE_DOS_HEADER)lpFileBase;
	peOffset = dosHeader->e_lfanew;
	peHeader = (PIMAGE_NT_HEADERS) ((char*) lpFileBase+peOffset);

	if ( peHeader->Signature != PE_SIGNATURE) 
	{
		printf("%s is not a valid PE\n", exePath);
		return 1;
	}

	fileHeader = (PIMAGE_FILE_HEADER) &peHeader->FileHeader;
	nSections = fileHeader->NumberOfSections;
	optHeader = (PIMAGE_OPTIONAL_HEADER)&peHeader->OptionalHeader;
	datDirectory = (PIMAGE_DATA_DIRECTORY)&optHeader->DataDirectory;
	resRVA = datDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress;
	secHeader = (PIMAGE_SECTION_HEADER) ((char*) optHeader+sizeof(IMAGE_OPTIONAL_HEADER));

	while(i++<nSections)
	{
		if (secHeader->VirtualAddress <= (DWORD)resRVA && secHeader->VirtualAddress + secHeader->SizeOfRawData > (DWORD)resRVA)
			break;
		secHeader++;
	}

	offFile = RVAToOffset (secHeader->VirtualAddress, secHeader);
	resDirectory = (PIMAGE_RESOURCE_DIRECTORY) ((char*)lpFileBase + offFile);
	
	baseResDirectory = resDirectory;
	count=0;
	m=0;
	p = parseDir(resDirectory);
	if (p != 0) {
		printf("Error while parsing resources directories\n");
		return 1;
	}

	UnmapViewOfFile(lpFileBase);
	CloseHandle(hFileMapping);
	CloseHandle(hFile);
	return 0;
}

void usage(char * name)
{
	printf("\nUsage: name [mode] [options] [file]\n\nMODE:\n -A   Add a resource\n -D   Dump resources\n" \
		"\nOPTIONS:\n\n [ADD Mode]\n -r   Resource to add\n -n   Resource name to add\n -t   Type of resource to add (optional)\n" \
		"\n [DUMP Mode]\n -v   Verbose (works only with Dump mode). Prints full directory tree, including every IMAGE_RESOURCE_DIRECTORY," \
		"IMAGE_RESOURCE_DIRECTORY_ENTRY, IMAGE_RESOURCE_DATA_ENTRY and IMAGE_RESOURCE_DIR_STRING.\n\n");
	return;
}

void main(int argc, char* argv[])
{
	/*if(argc == 1)
	{
		usage(argv[0]);
		return;
	}
*/

	int foo = 0;

	foo = parsePE("E:\\marc.exe");
	if ( foo != 0) {
		printf("Error while parsing\n\n");
	}

	//addRes("E:\\marc.exe", "E:\\marc_res2.txt", "drv");
	//addRes("E:\\marc.exe", "E:\\ressys.txt", "sys1");
	//check_add();
	
	return;
}
