%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
void yyerror(char *);
extern int counter;
extern int post;
extern int contLength;
extern int digit;
extern int correct;
extern int errorCounter;
%}

%option yylineno

%%

[a-z]          		{//printf("CHAR"); 
						return CHAR;}

"Connection:"		{//printf("Connection:"); 
return CONNECTION;} 

"chunked"	       	{//printf("chunked"); 
return TRANSFER_ENCODING;}

"gzip"          	{//printf("gzip"); 
return TRANSFER_ENCODING;}

"deflate"       	{//printf("deflate"); 
return TRANSFER_ENCODING;}

"HTTP"          	{//printf("HTTP"); 
return HTTP;}

"Accept-Charset:"   {//printf("ACCEPT-CHARSET ");
 return ACCEPT_CHARSET;}

"http://"       	{ //printf("http://"); 
return HTTPURI;}

"Date:"         	{//printf("DATE:");
 return DATE_TOKEN;}

"User-Agent:"   	{//printf("USER_AGENT");
 return USER_AGENT;}

"ISO"           	{//printf(" ISO ");
 return ISO;}

"/"         	    {return SLASH;}

"*"     	        {return STAR;}

":"		            {return DOUBLE_DOT;}

"."            		{return DOT;}

"GET"           	{//printf("-----> GET ");
 post=0; return METHOD;}

"HEAD"      	    {//printf("-----> HEAD ");
 post=0; return METHOD;}

"POST" 		        {//printf("-----> POST ");
 post=1; return METHOD;}

"Content-Lenght:"   {//printf("Content-Length");
 return CONTENT_LENGTH;}

"Expires:"      	{//printf("Expires:");
 return EXPIRES;}

"Referer:" 		    {//printf("Referer\n");
 return REFERER;}

[a-zA-Z][a-zA-Z]+ 	{//printf("WORD"); 
return WORD;}

[0-9]      			{//printf("DIGIT ");
 digit=atoi(yytext); return DIGIT;}

[1-9]+"."[0-9]+ 	{//printf("FLOAT ");
 return FLOAT;}

[-+()=/.*]			{return *yytext;}

\n         			{//printf("\n NEW LINE \n");
 return CRLF;}

[ \t] ;	/*skip whitespace*/

.              		{yyerror("Unkown Character");}

%%

int yywrap(void)
{
	return 1;
}

void yyerror(char * str)
{
	correct=1;
	errorCounter++;
    fprintf(stdout, "Error -> %s: Line %d\n", str, yylineno);
}

