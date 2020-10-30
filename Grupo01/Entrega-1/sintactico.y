%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "sintactico.tab.h"
int yystopparser=0;
FILE  *yyin;
int insertarEnTS(char[],char[],int);
%}

%union {
int int_val;
double float_val;
char *str_val;
}

%token PROGRAM
%token DEFINE
%token ENDDEFINE
%token CONST_INT
%token CONST_REAL
%token CONST_STR
%token ID
%token REAL
%token FLOAT
%token INT
%token PYC
%token STRING
%token BEGINP
%token ENDP
%token IF THEN ELSE ENDIF
%token LET
%token FOR TO DO ENDFOR
%token WHILE ENDW
%token REPEAT UNTIL
%token OP_LOG
%token OP_NOT
%token OP_DOSP
%token OP_COMPARACION
%token OP_ASIG
%token OP_SUM
%token OP_RES
%token OP_DIV
%token OP_MULT
%token COMA
%token P_A P_C
%token C_A C_C
%token LONG
%token IN
%token DEFVAR
%token ENDDEF
%token GET
%token DISPLAY

%%
programa:  
        PROGRAM {printf("COMPILACION INICIADA\n");}
        codigo
        {printf("COMPILACION EXITOSA\n");}
        ;

codigo: 
        BEGINP bloqueTemasComunesYEspeciales ENDP
      
        ;

bloqueTemasComunesYEspeciales: 
                  temaComunYEspecial
                  | bloqueTemasComunesYEspeciales temaComunYEspecial
                  ;


temaComunYEspecial: 
            iteracion {printf("--------------------------ITERACION\n\n\n");}
          | decision {printf("--------------------------DECISION\n\n\n");}
          | bloqueDeclaracion {printf("--------------------------BLOQUE_DECLARACION\n\n\n");}
          | listavariables {printf("--------------------------LISTA_VARIABLES\n\n\n");}
          | asignacion {printf("--------------------------ASIGNACION\n\n\n");}
          | entrada {printf("--------------------------ENTRADA\n\n\n");}
          | salida {printf("--------------------------SALIDA\n\n\n");}
          | condicion {printf("--------------------------CONDICION\n\n\n");}
          | expresion {printf("--------------------------EXPRESION\n\n\n");}
          | termino {printf("--------------------------TERMINO\n\n\n");}
          | factor {printf("--------------------------FACTOR\n\n\n");}
          | listaVarLetDer {printf("--------------------------LISTA_VARIABLES_LET_DERECHA\n\n\n");}
          | listaVarLetIzq {printf("--------------------------LISTA_VARIABLES_LET_IZQUIERDA\n\n\n");}
          | declaracion {printf("--------------------------DECLARACION\n\n\n");}
          | declaraciones {printf("--------------------------DECLARACIONES\n\n\n");}
          | tipodato {printf("--------------------------TIPO_DE_DATO\n\n\n");}
		  | ifUnario {printf("--------------------------IF_UNARIO\n\n\n");}
          | let {printf("--------------------------LET\n\n\n");}
        ;


asignacion: ID OP_ASIG expresion ;

iteracion: WHILE P_A condicion P_C bloqueTemasComunesYEspeciales ENDW ;

ifUnario: ID OP_ASIG IF P_A condicion COMA expresion COMA expresion P_C ;

decision: IF P_A condicion P_C THEN bloqueTemasComunesYEspeciales ENDIF
          | IF P_A condicion P_C THEN bloqueTemasComunesYEspeciales ELSE  bloqueTemasComunesYEspeciales ENDIF
          ;

condicion: comparacion 
           | condicion OP_LOG comparacion
           |OP_NOT comparacion
           ;

comparacion: expresion OP_COMPARACION expresion 
            | P_A expresion OP_COMPARACION expresion P_C
            ;

expresion: expresion OP_SUM termino
         | expresion OP_RES termino
         | termino
          ;

termino: factor
        | termino OP_DIV factor
        | termino OP_MULT factor
        ;

factor: ID  
        | CONST_INT
        | CONST_STR 
        | CONST_REAL 
      ;

let: LET listaVarLetIzq OP_ASIG P_A listaVarLetDer P_C
    ;
 
listaVarLetIzq: ID
              | listaVarLetIzq COMA ID
              ;
 
listaVarLetDer: expresion
              | listaVarLetDer PYC expresion
              ;

bloqueDeclaracion: DEFVAR declaraciones ENDDEF 
                  ;

declaraciones: declaracion
              | declaraciones declaracion
              ;           

declaracion: tipodato OP_DOSP listavariables          
            ;

tipodato: FLOAT 
        | STRING 
        |  INT 
        ;

listavariables: ID  
              | listavariables PYC ID
              ;


entrada: GET ID 
        ;

salida: DISPLAY factor 
        ;

%%

int main(int argc,char *argv[])
{
  if ((yyin = fopen(argv[1], "rt")) == NULL)
  {
	printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  }
  else
  {
	yyparse();
  }
  fclose(yyin);
  return 0;
}
int yyerror(void)
     {
       printf("Syntax Error\n");
	 system ("Pause");
	 exit (1);
     }


int nuevoSimbolo(char tilineasiguienteimbolo[],char valorString[],int longitud){
  FILE *tablasimbolos = fopen("ts.txt","rw");
  char lineaescrita[100];
  char valorBuscado[100];
  char linealeida[100];
  char *lineasiguiente;
  int encontro = 0;
  int i = 0;
  sprintf(lineaescrita, (longitud != 0)? 
          "%s|%s|%s|%d":
          "%s|%s|%s|--",
          yylval.str_val,tilineasiguienteimbolo,valorString,longitud);

  lineasiguiente = fgets(linealeida,100,tablasimbolos);
  while(lineasiguiente  && !encontro){
	  strcpy(valorBuscado,lineaescrita);
	  strcat(valorBuscado,"\n");
    encontro = !strcmp(valorBuscado,linealeida);
	  lineasiguiente = fgets(linealeida,100,tablasimbolos);
  }
  fclose(tablasimbolos);
  tablasimbolos = fopen("ts.txt","a");
  if(!encontro){
    fprintf(tablasimbolos,"%s\n",lineaescrita);
  }
  fclose(tablasimbolos);
}

