%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include "sintactico.tab.h"
#define COTA_INT 65536
#define COTA_FLOAT 4294967296
FILE  *yyin;
%}
%option noyywrap  
%option yylineno 

DIGITO		    [0-9]
LETRA		    [a-zA-Z]
COMA            [","]
COM_INI         ["***/"]    
COM_FIN         ["/***"]
COMENTARIOS     ["***/"]({LETRA}|{DIGITO}|.)*["/***"]
CONST_STR       \"(({LETRA}|{DIGITO}|[\?\¿\!\¡=#$%()\[\]{}_-]){0,30})\"
CONST_REAL      {DIGITO}+"."{DIGITO}+
CONST_INT       {DIGITO}+
ID			    {LETRA}({LETRA}|{DIGITO}|_)*
	


%% 
"program"		{ return PROGRAM;}
"define"		{ return DEFINE;}
"enddefine"		{ return ENDDEFINE;}
"beginp"		{ return BEGINP;}
"endp"			{ return ENDP;}
"real"			{ return REAL;}
"string"		{ return STRING;}
"if"			{ return IF;}
"let"			{ return LET;}
"then"   		{ return THEN;}
"else"   		{ return ELSE;}
"endif"	      	{ return ENDIF;}
"for"			{ return FOR;}
"to"		   	{ return TO;}
"do"	        { return DO;}
"endfor"		{ return ENDFOR;}
"while"	      	{ return WHILE;}
"in"	        { return IN;}
"endw"  		{ return ENDW;}
"repeat"		{ return REPEAT;}
"until"			{ return UNTIL;}
"defvar"  		{ return DEFVAR;}
"enddef"  		{ return ENDDEF;}
"float"  		{ return FLOAT;}
"int"  		    { return INT;}
"display"       { return DISPLAY;}
"get"           { return GET;}
"and"           { return OP_AND;}
"or"            { return OP_OR;}
"not"           { return OP_NOT;}
":="			{ return OP_ASIG;}
":"		    	{ return OP_DOSP;}
"+"		    	{ return OP_SUM;}
"-"		    	{ return OP_RES;}
"*"		    	{ return OP_MULT;}
"/"		    	{ return OP_DIV;}
"("		    	{ return P_A;}
")"		    	{ return P_C;}
"="         { return ASIG;}
">"             { return OP_MAYOR;}
">="            { return OP_MAYORIGUAL;}
"=="            { return OP_IGUAL;}
"<"             { return OP_MENOR;}
"<="            { return OP_MENORIGUAL;}
"<>"            { return OP_DISTINTO;}
";"             { return PYC;}
"and"           { return OP_AND;}
"or"            { return OP_OR;}
"not"           { return OP_NOT;}


{ID}		        {
                     yylval.str_val = strdup(yytext);
                    return ID;
                }

{CONST_INT}	    {   
                    yylval.str_val = strdup(yytext);

                 
                    if( atoi(yytext) > COTA_INT){
                      printf("Cota int superada");
                     
                    } 

                    sprintf(yylval.str_val,"_%s",yytext); 
    			          nuevoSimbolo("--",yytext,0);		
                    return CONST_INT;
                }

{CONST_STR}		{     
                    //Quita las comillas. yytext se utiliza para asignar "valor" en la TS. yylval se utiliza para asignar "nombre" en la TS
                    memcpy(yytext, &yytext[1], strlen(yytext)-2);
                    yytext[strlen(yytext)-2] = '\0';

                    sprintf(yylval.str_val,"_%s",yytext);
                    nuevoSimbolo("--",yytext,strlen(yytext));
                    return CONST_STR;
                }

{CONST_REAL}    {       
                    yylval.str_val = strdup(yytext);

                      if( atoi(yytext) > COTA_FLOAT){
                      printf("Cota FLOAT superada");
                     
                    } 

                    sprintf(yylval.str_val,"_%s",yytext);
                    nuevoSimbolo("--",yytext,0);
                    return CONST_REAL; 
                }
                

{COMA}			{ return COMA;}
{COMENTARIOS}	{ return COMENTARIOS;}
\n   
" "
"\t"
%%


