#include <DIR.H>
#include <STRING.H>
#include <STDIO.H>
#include <FSTREAM.H>

//есть ли данный файл на диске
char fileExists( char *name )
{
    struct ffblk sr;
    int ccode;

    ccode = findfirst(name, &sr, 0);
    if (!ccode)
	return 1;
    else
	return 0;
}

char removeSemicolon(char *fileIn,char *fileOut)
{
char fileRead[MAXPATH];
char fileSave[MAXPATH];
char userInput[10];
fileRead[0]=0;
 char *p;
 if ((p=strchr(fileIn,'.'))==0){
  strcpy(fileRead,fileIn);
  strcat(fileRead,".ASM");
  if (fileOut[0]==0){
   strcpy(fileSave,fileIn);
   strcat(fileSave,".C");
   }
  }
 else{
  strcpy(fileRead,fileIn);
  if (fileOut[0]==0){
   strncpy(fileSave,fileIn,p-fileIn);
   fileSave[p-fileIn]=0;
   strcat(fileSave,".C");
   }
  }
 if (!fileExists(fileRead)) return 5;
 ifstream f( fileRead, ios::in | ios::binary );
 char rs[128];
 if( !f )
  {
   return 1;
  }
 if (fileExists(fileSave)){
  printf("Файл %s уже сущетсвует! Переписать?(Y/N)",fileSave);
  scanf("%s",userInput);
  if (userInput[0]!='Y' && userInput[0]!='y')
   return 6;
  }
 ofstream f1(fileSave, ios::out| ios::binary );
 if (!f1)
  {
   return 2;
  }
 while (!f.eof()){
  int i;
  f.getline( rs, sizeof(rs));
  if (rs[0]==0 ) continue;
  if( !f ) { return 3;}
  i=0;
//  while (rs[i]!=0) {
//   if (rs[i]==' ') {i++;continue;}
//   break;
//   }
  if (rs[i]==';'){
   rs[i]=' ';
   f1.write(rs+1,strlen(rs+1));
   if( !f1 ) { return 4;}
   f1.write("\n",1);
   if( !f1 ) { return 4;}
   }
  }
return 0;

}
void main(int argc, char **argv)
{

char fileName[MAXPATH];
char fileNameOut[MAXPATH];
fileName[0]=0;
fileNameOut[0]=0;
 printf("\n"
	"Конвертер asm -> cpp. Version 0.1\n");
 printf(" (c) Peter Telegin Ltd. 1999-2000\n");
if (argc==1){
 printf(" convert.exe <filename>[.asm] [filename.c]\n");
 }
else{
 if (argc==2) strcpy(fileName,argv[1]);
 if (argc==3) strcpy(fileNameOut,argv[2]);
 switch(removeSemicolon(fileName,fileNameOut)){
  case 0:
   printf("файл успешно преобразован\n");
   break;
  case 1:
   printf("Ошибка открытия входного файла\n");
   break;
  case 5:
   printf("Входной файл не найден\n");
   break;
  case 2:
   printf("Ошибка открытия выходного файла\n");
   break;
  case 3:
   printf("Ошибка чтения входного файла\n");
   break;
  case 4:
   printf("Ошибка записи выходного файла\n");
   break;
  case 6:
   printf("Хорошо, переписывать не будем, укажи другое имя.\n");
   break;
  }
 }


}