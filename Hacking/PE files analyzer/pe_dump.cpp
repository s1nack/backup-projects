#include <windows.h>
#include <winnt.h>
#include <stdio.h>

#define PE_SIGNATURE 0x4550
#define DEBUG 1

int drv_pe_dump (char *exePath);
unsigned char checkMSB(ULONG checked_var);

void main()
{
	int foo = 0;
	foo = drv_pe_dump("E:\\marc.exe");
	if ( foo != 0)
	{
		printf("erreur dans drv_pe_dump\n\n");
	}
	return;
}

unsigned char checkMSB(ULONG checked_var)
{
	unsigned char flag = 0;
	//if (checked_var & (1 << 32))
	printf("var : 0x%08X\n", checked_var);
	if (checked_var & 0x80000000) {
	    printf(" bit setn");
		flag = 1;
	}
	else { 
	    printf("bit not set\n");
		flag = 0;
	}
	printf("\n%08X\n80000000\n", checked_var);
	return flag;
}

int drv_pe_dump (char *exePath) 
{
	HANDLE hFile;
	HANDLE hFileMapping;
	LPVOID lpFileBase;
	DWORD imgBase;
	PIMAGE_DOS_HEADER dosHeader;
	PIMAGE_NT_HEADERS peHeader;
	PIMAGE_FILE_HEADER fileHeader;
	PIMAGE_OPTIONAL_HEADER optHeader;
	PIMAGE_DATA_DIRECTORY datDirectory;
	PIMAGE_RESOURCE_DIRECTORY resDirectory;
	PIMAGE_RESOURCE_DIRECTORY_ENTRY resEntry;
	//PIMAGE_RESOURCE_DATA_ENTRY resDataEntry;
	LONG peOffset;
	ULONG resRVA;
	USHORT nSections = 0;
	unsigned char msb = 0;

	hFile = CreateFile(exePath, GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
	if ( hFile == INVALID_HANDLE_VALUE )
	{
		printf("Can't open file. Exiting.\n");
		return 1;
	}

	hFileMapping = CreateFileMapping(hFile,NULL,PAGE_READONLY,0,0,NULL);
	if ( hFileMapping == 0 )
	{
		printf("Can't create file mapping. Exiting.\n");
		return 1;
	}

	lpFileBase = MapViewOfFile(hFileMapping,FILE_MAP_READ,0,0,0);
	if ( lpFileBase == 0 )
	{
		printf("Can't map file in memory. Exiting.\n");
		return 1;
	}

	printf("%s\n\n", exePath);
	
	dosHeader = (PIMAGE_DOS_HEADER)lpFileBase;
	peOffset = dosHeader->e_lfanew;
	peHeader = (PIMAGE_NT_HEADERS) ((char*) lpFileBase+peOffset);

#ifdef DEBUG
	printf("PE Signature: %x\n", peHeader->Signature);
#endif

	if ( peHeader->Signature != PE_SIGNATURE) 
	{
		printf("%s PE header signature is incorrect.\n", exePath);
		return 1;
	}

	fileHeader = (PIMAGE_FILE_HEADER) &peHeader->FileHeader;
	nSections = fileHeader->NumberOfSections;
	optHeader = (PIMAGE_OPTIONAL_HEADER)&peHeader->OptionalHeader;
	imgBase = optHeader->ImageBase;
	datDirectory = (PIMAGE_DATA_DIRECTORY)&optHeader->DataDirectory;
	resRVA = datDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress;

	PIMAGE_SECTION_HEADER secHeader;
	secHeader = (PIMAGE_SECTION_HEADER) ((char*) optHeader+sizeof(IMAGE_OPTIONAL_HEADER));

	int i=0;
	while(i++<nSections)
	{
		if (secHeader->VirtualAddress <= (DWORD)resRVA && secHeader->VirtualAddress + secHeader->SizeOfRawData > (DWORD)resRVA)
			break;
		secHeader++;
	}
/*
#ifdef DEBUG
	printf("image base: 0x%08X\n", imgBase);
	printf("%d sections dans les headers\n\n", nSections);
	printf("section: %s \n", secHeader->Name);
	printf("Physical Address -> 0x%08X\n", secHeader->Misc.PhysicalAddress);
	printf("Virtual Size -> %08X\n", secHeader->Misc.VirtualSize);
	printf("Virtual Address -> 0x%08X \n", secHeader->VirtualAddress);
	printf("Size of raw data -> %08X \n", secHeader->SizeOfRawData);
	printf("Pointer to raw data -> 0x%08X \n", secHeader->PointerToRawData);
	printf("Pointer to relocation -> 0x%08X\n", secHeader->PointerToRelocations);
	printf("Pointer to line numbers -> 0x%08X \n", secHeader->PointerToLinenumbers);
#endif // section headers de la section .rsrc
*/
	resDirectory = (PIMAGE_RESOURCE_DIRECTORY) (imgBase + secHeader->VirtualAddress);
#ifdef DEBUG
	printf("SECTION .rsrc\n");
	printf("Characteristics -> %08X\n", resDirectory->Characteristics);
	printf("TimeDateStamp -> %08X\n", resDirectory->TimeDateStamp);
	printf("MajorVersion -> %04X\n", resDirectory->MajorVersion);
	printf("MinorVersion -> %04X\n", resDirectory->MinorVersion);
	printf("NumberOfNamedEntries -> %04X\n", resDirectory->NumberOfNamedEntries);
	printf("NumberOfIdEntries -> %04X\n", resDirectory->NumberOfIdEntries);
#endif 
	resEntry = (PIMAGE_RESOURCE_DIRECTORY_ENTRY) (imgBase + secHeader->VirtualAddress + sizeof(IMAGE_RESOURCE_DIRECTORY));
#ifdef DEBUG
	printf("IMAGE RESOURCE DIRECTORY ENTRY -> name = %08X\n", resEntry->Name);
	printf("IMAGE RESOURCE DIRECTORY ENTRY -> offsettodata = %08X\n", resEntry->OffsetToData);
#endif
	printf("\n\n\n");
	printf("IMAGE RESOURCE DIRECTORY ENTRY -> name = %08X\n", resEntry->Name);
	msb = checkMSB(resEntry->Name);
	if (msb == 1)
		printf("MSB set on resEntry->Name\n");
	else
		printf("MSB not set on resEntry->Name\n");
	printf("IMAGE RESOURCE DIRECTORY ENTRY -> offsettodata = %08X\n", resEntry->OffsetToData);
	msb = checkMSB(resEntry->OffsetToData);
	if (msb == 1)
		printf("MSB set on resEntry->OffsetToData\n");
	else
		printf("MSB not set on resEntry->OffsetToData\n");
/*
#ifdef DEBUG
	printf("OffsetToData = %08X\n", resDataEntry->OffsetToData);
	printf("Size = %08X\n", resDataEntry->Size);
	printf("CodePage = %08X\n", resDataEntry->CodePage);
	printf("Reserved = %08X\n", resDataEntry->Reserved);
#endif
*/
	Sleep(5000);

	UnmapViewOfFile(lpFileBase);
	CloseHandle(hFileMapping);
	CloseHandle(hFile);

	return 0;
}