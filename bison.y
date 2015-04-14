%{
#include <stdio.h>
void yyerror(char *);
extern FILE* yyin;
extern int yylineno;
int counter=0;
int contLength=0;
int digit;
int post;
int correct=0;
int errorCounter=0;
%}

%token CHAR
%token HTTP
%token METHOD
%token GET
%token WORD
%token TRANSFER_ENCODING
%token CONNECTION
%token EXPIRES
%token CONTENT_LENGTH
%token REFERER
%token DATE_TOKEN
%token HTTPURI
%token ACCEPT_CHARSET
%token ISO
%token USER_AGENT
%token DIGIT
%token CRLF
%token SLASH
%token STAR
%token DOT
%token DOUBLE_DOT
%token FLOAT

%%

request:
        request_line CRLF message_body                  
    |   request_line CRLF                               
    |   request_line temp_request CRLF message_body     
    |   request_line temp_request CRLF                  
    |   request_line CRLF error 
    |   request_line error message_body
    |   request_line error 
    |   error CRLF message_body
    |   error CRLF
    |   request_line temp_request CRLF error
    |   request_line temp_request error message_body
    |   request_line error CRLF message_body
    |   error temp_request CRLF message_body
    |   request_line temp_request error
    |   request_line error CRLF
    |   error temp_request CRLF
    |   error
    ;

request_line:
        METHOD request_uri http_version
    ;

temp_request:
        general_header temp_request
    |   request_header temp_request
    |   entity_header 									
    |   CRLF temp_request
    ;

request_uri:
        STAR
	|   absoluteURI
    |   abs_path
;


date:
        DIGIT DIGIT SLASH DIGIT DIGIT SLASH DIGIT DIGIT DIGIT DIGIT  DIGIT DIGIT DOUBLE_DOT DIGIT DIGIT 
    ;

abs_path:
        WORD
    ;

http_version:
        HTTP SLASH FLOAT
    ;
    

referer:
        REFERER absoluteURI 
    |   REFERER relativeURI 
    ;

absoluteURI:
    HTTPURI relativeURI
    ;

relativeURI:
    WORD
    | WORD tempRelativeURI relativeURI
    | integer tempRelativeURI relativeURI 
    | FLOAT tempRelativeURI relativeURI    
    |
    ;

tempRelativeURI:
        DOT
    |   SLASH
    ;

request_header:
        accept_charset
    |   referer
    |   user_agent
    ;

user_agent:
        USER_AGENT product CRLF 
    ;

product:
        WORD 
    |   product tempProduct FLOAT
    |   product tempProduct integer
    ;

tempProduct:
        DOT
    |   '-'
    |   SLASH
    ;


accept_charset:
        ACCEPT_CHARSET charset
    |   ACCEPT_CHARSET STAR
    ;

charset:
        ISO '-' integer '-' integer
    ;

date_str:
    DATE_TOKEN date                          
    ;

general_header:
        connection
    |   date_str
    |   TRANSFER_ENCODING
    ;

connection:
        CONNECTION WORD
    ;

entity_header:
        content_length CRLF expires CRLF 
    |   content_length CRLF 
    |   expires CRLF        
    ;

expires:
        EXPIRES date
    ;

content_length:
       CONTENT_LENGTH integer {contLength = digit;}
    ;

message_body:
        WORD                {counter++;}
    |   message_body WORD   {counter++; }
    ;


integer:
        integer DIGIT   
    |   DIGIT           
    ;


%%

int main(int argc, char* argv[])
{
    if(argc != 2)
    {
        printf("No input file!\n");
        return 1;
    }
    FILE *fp;
    if( (fp = fopen(argv[1], "r") ) )
    {        
        yyin = fp;
        yyrestart(fp);
        yyparse();

        if(post == 1)
        {
            if( counter == 0 )
            {
                printf("Message body missing \n");
                correct = 1;
            }

            if(counter != contLength)
            {
                correct = 1;
                printf("Wrong Content Length\n");
                return 0;
            }
        }
        
        if (correct==0)
            printf("Correct syntax!\n");
        else
            printf("\n%d errors generated \n", errorCounter);    
    }
    else
        printf("Cannot open file \n");
    return 0;
}
