%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "sintactico.tab.h"
int yystopparser=0;
int posicion = 0;
int indice = 0;

//para controlar la cantidad de saltos por falso en los cliclos anidados
int vecFalsosAnidados[30];
int cantCliclosAnidados=0;
int cantFalsos=0;
FILE  *yyin;
char operador[30];
char* tipoDato;
char idAsigna [30];
char tipoDatoActual[50] = "";
char res[30];
int posWhileInicial;
//////////////////////PILA
	typedef struct
	{
		int posicion;
	}t_info;

	typedef struct s_nodoPila{
    	t_info info;
    	struct s_nodoPila* psig;
	}t_nodoPila;

	typedef t_nodoPila *t_pila;

        typedef struct
	{
		char* tipoDato;
                char nombre[25];
	}t_infoIds;

        typedef struct s_nodoPilaIds{
    	t_infoIds infoIds;
    	struct s_nodoPilaIds* psig;
	}t_nodoPilaIds;


	typedef t_nodoPilaIds *t_pilaIds;

/////////////////////POLACA
	typedef struct
	{
		char contenido[30];
		int posicion;
	}t_infoPolaca;
  
         typedef struct s_nodoPolaca{
                t_infoPolaca info;
                struct s_nodoPolaca* psig;
	}t_nodoPolaca;

	typedef t_nodoPolaca* t_polaca;
        
        typedef struct
	{
		char nombreVariable[30];
		char tipoVariable[30];

	}t_variables;

//para operadores en assembler
typedef struct
{
        char nombreOperador[30];
}t_operador;

typedef struct
{
        char nombrePalabraReservada[30];
}t_palabraReservada;

////////para pila de operandos

typedef struct
{
        char nombre[30];
}t_infoOperandos;

typedef struct s_nodoPilaOperandos{
t_infoOperandos infoOperandos;
struct s_nodoPilaOperandos* psig;
}t_nodoPilaOperandos;


typedef t_nodoPilaOperandos *t_pilaOperandos;
////////para TS
typedef struct s_dato_TS
{
  char nombre[32];
  char tipo[32];
  char valor[32];
  int longitud;
} t_dato_TS;

typedef struct s_nodo_TS
{
  t_dato_TS dato;
  struct s_nodo_TS *sig;
} t_nodo_TS;

typedef t_nodo_TS* t_TS;
/////////////////DECLARACION FUNCIONES
int apilar(t_pila* pila,const int iPosicion);
int desapilar(t_pila *pila);
void crearPila(t_pila* pila);
void VaciarPila(t_pila* pila);
int pilaVacia(t_pila* pila);


void crearPilaIds(t_pilaIds* pilaIds);
char *  desapilarId(t_pilaIds *pilaIds);
int apilarId(t_pilaIds* pilaIds,const t_infoIds* infoPilaIds);
void  mostrarPilaIDs(t_pilaIds* );

void crearPolaca(t_polaca* );
int insertarPolaca(t_polaca*,char*);
int escribirPosicionPolaca(t_polaca* ,int , char*);
void guardarArchivoPolaca(t_polaca*);
void  mostrarPilaIDs(t_pilaIds* );
int nuevoSimbolo(char* tipoDato,char* valorString,int longitud);
char* invertir_salto(char* comp);
void liberarPolaca(t_polaca *polaca);

void mostrarArrayVariables(t_variables* );
void validarDeclaracionID(char *);
char * obtenerTipoDeDato(char *);
char * buscarTipoDeDatoEnTS(t_TS* ts,char* nombreID);


////////FUNCIONES PARA ASSEMBLER
void generarCodigoUsuario(FILE* finalFile, t_polaca* polaca,t_TS* TS);
void generarAsm(t_TS* );
void llenarVectorOperadores(t_operador [30]);
void llenarVectorPalabrasReservadas(t_palabraReservada [30]);
t_operador vectorOperadores[32];
t_palabraReservada vectorPalabrasReservadas [30];
int esOperador(char valor[32]);
int esPalabraReservada(char valor[32]);

//estructura ts
int insertarEnTS(t_TS*,t_dato_TS*);
void crearTS(t_TS *);
void liberarTS(t_TS*);
t_TS TS;
//validation tipos de dato
void validarPermisoDeDeclaracionID(char *);
//pila operandos
void crearPilaOperandos(t_pilaOperandos* pilaOperandos);
int apilarOperando(t_pilaOperandos* pilaOperandos,char nombreOperando[30]);
char* desapilarOperando(t_pilaOperandos *pilaOperandos);
int pilaOperandoVacia(t_pilaOperandos* ppilaOperando);
//declaracion de variables
t_pila pila;
char comp[3];
char op[3];
char idValor[25];
int cantComparaciones=0;
int contWhile=0,contElse=0,contEndW=0,contThen=0,contEndif=0, contThenW=0;

t_pila pilaFalso;
t_pila pilaVerdadero;
t_pilaIds pilaIds;
int posicionPolaca = 0;
t_polaca polaca;
t_variables arrayVariables[500];
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
%token OP_OR
%token OP_AND
%token OP_NOT
%token OP_DOSP
%token OP_IGUAL
%token OP_MAYOR
%token OP_MAYORIGUAL
%token OP_MENOR
%token OP_MENORIGUAL
%token OP_DISTINTO
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
%token COMENTARIOS
%token ASIG

%%
programa:  
        PROGRAM {printf("COMPILACION INICIADA\n");}
        codigo
        {printf("COMPILACION EXITOSA\n");}
        ;

codigo: 
       BEGINP bloqueTemasComunesYEspeciales ENDP
      |BEGINP bloqueDeclaracion {printf("--------------------------BLOQUE_DECLARACION\n\n\n");}
      bloqueTemasComunesYEspeciales ENDP
      |BEGINP bloqueDeclaracion  {printf("--------------------------BLOQUE_DECLARACION\n\n\n");}  ENDP
        ;

bloqueTemasComunesYEspeciales: 
                  temaComunYEspecial
                  | bloqueTemasComunesYEspeciales temaComunYEspecial
                  ;


temaComunYEspecial: 
            iteracion {printf("--------------------------ITERACION\n\n\n");}
          | seleccion {printf("--------------------------DECISION\n\n\n");}
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
          | tipodato {printf("--------------------------TIPO_DE_DATO\n\n\n");}
	  | ifUnario {printf("--------------------------IF_UNARIO\n\n\n");}
          | let {printf("--------------------------LET\n\n\n");}
          | COMENTARIOS {printf("--------------------------COMENTARIO\n\n\n");}
        ;


                        
asignacion: ID { validarDeclaracionID(yylval.str_val); strcpy(tipoDatoActual,obtenerTipoDeDato(yylval.str_val));  insertarPolaca(&polaca,yylval.str_val); } OP_ASIG expresion {insertarPolaca(&polaca,"OP_ASIG"); strcpy(tipoDatoActual,"");}
                ;

iteracion: WHILE {
                if(!cantCliclosAnidados)
                        posWhileInicial = insertarPolaca(&polaca,"WHILE");
                else{
                        int pos = insertarPolaca(&polaca,"WHILE");
                        apilar(&pilaVerdadero, pos);
                }
                cantCliclosAnidados++; 
                //guardamos la cantidad de saltos por falso que tiene el if anidado anterior
                if(cantCliclosAnidados>1){ 
                        vecFalsosAnidados[cantCliclosAnidados-2] = cantFalsos;
                        cantFalsos = 0;
                        }
                }  
        P_A condicion{
                 cantComparaciones = 0;
        } P_C
        {
                char spos[25]; 
                int pos = insertarPolaca(&polaca,"THENW");
                sprintf(spos,"%d",pos);
                if(cantCliclosAnidados>1)
                escribirPosicionPolaca(&polaca,desapilar(&pilaVerdadero),spos);
        }
         bloqueTemasComunesYEspeciales ENDW {
        int posicionInicial, posicionBranch, falsosADesapilar = (cantFalsos ==2)?1:0;
        char posFalso[25];
        char posInicio[25];
      
        if(cantCliclosAnidados == 1)
                posicionInicial = posWhileInicial;
        else
                posicionInicial = desapilar(&pilaVerdadero); 
        sprintf(posInicio,"%d",posicionInicial);
        insertarPolaca(&polaca,"JMP");
        escribirPosicionPolaca(&polaca,insertarPolaca(&polaca,""),posInicio);

        sprintf(posFalso,"%d",insertarPolaca(&polaca,"ENDW"));
         while(!pilaVacia(&pilaFalso) &&falsosADesapilar>=0){
                posicionBranch = desapilar(&pilaFalso); 
                escribirPosicionPolaca(&polaca,posicionBranch,posFalso);
                falsosADesapilar--;
        }
        //actualizamos la cantidad de falsos que tenia el if anterior
        cantFalsos = vecFalsosAnidados[cantCliclosAnidados-2];
        //reducimos la cant de cantCliclosAnidados
        cantCliclosAnidados--;

        };


ifUnario: ID{   validarDeclaracionID(yylval.str_val); strcpy(tipoDatoActual,obtenerTipoDeDato(yylval.str_val)); 
                strcpy(idValor,yylval.str_val);//guardamos en char* el yyval del id
        } 
        ASIG IF P_A condicion COMA {
                //desapilar pilaVerdadero
                int posicionBranch;
                char posActual[25];
                sprintf(posActual,"%d",posicionPolaca);
                while(!pilaVacia(&pilaVerdadero)){
                        posicionBranch = desapilar(&pilaVerdadero); 
                        escribirPosicionPolaca(&polaca,posicionBranch,posActual);
                }

        }
        expresion{
                insertarPolaca(&polaca,idValor);
                insertarPolaca(&polaca,"OP_ASIG");
                insertarPolaca(&polaca,"JMP");
                apilar(&pilaVerdadero,insertarPolaca(&polaca,""));
        } 
        COMA{
                insertarPolaca(&polaca,"ELSE");
                //desapilar pilaFalso.
                int posicionBranch;
                char posActual[25];
                sprintf(posActual,"%d",posicionPolaca-1);
                while(!pilaVacia(&pilaFalso)){
                        posicionBranch = desapilar(&pilaFalso); 
                        escribirPosicionPolaca(&polaca,posicionBranch,posActual);
                }
        }

        expresion{
                insertarPolaca(&polaca,idValor);
                insertarPolaca(&polaca,"OP_ASIG");
        } 
        P_C {
                int posicionBranch;
                char posActual[25];
                sprintf(posActual,"%d",posicionPolaca);
                if(!pilaVacia(&pilaVerdadero)){
                        posicionBranch = desapilar(&pilaVerdadero); 
                        escribirPosicionPolaca(&polaca,posicionBranch,posActual);
                }
                strcpy(tipoDatoActual,"");
                insertarPolaca(&polaca,"ENDIF");
        }; 

seleccion: seleccionSinElse finSeleccion;

seleccionSinElse: IF {
                cantCliclosAnidados++; 
                //guardamos la cantidad de saltos por falso que tiene el if anidado anterior
                if(cantCliclosAnidados>1){ 
                        vecFalsosAnidados[cantCliclosAnidados-2] = cantFalsos;
                        cantFalsos = 0;
                        }
                } 
        P_A condicion{
                 cantComparaciones = 0;
        }
        P_C THEN{
                insertarPolaca(&polaca,"THEN");
                int iPosicion;
                char posThen[25];
                //salto por verdadero
                sprintf(posThen,"%d",posicionPolaca-1);
                if(!pilaVacia(&pilaVerdadero)){
                iPosicion = desapilar(&pilaVerdadero); 
                escribirPosicionPolaca(&polaca,iPosicion,posThen);
                }
        }
        bloqueTemasComunesYEspeciales{
                insertarPolaca(&polaca,"JMP");
                apilar(&pilaFalso,insertarPolaca(&polaca,""));
                
        }
        ;

finSeleccion: ELSE{
                insertarPolaca(&polaca,"ELSE");
                int posicionBranch, falsosADesapilar = (cantFalsos ==2)?1:0, posAux;
                char sPosicionPolaca[25];
                sprintf(sPosicionPolaca,"%d",posicionPolaca-1);
                //desapilo salto de BI
                posAux = desapilar(&pilaFalso);
                while(!pilaVacia(&pilaFalso) && falsosADesapilar>=0){
                        //salto por falso
                        posicionBranch = desapilar(&pilaFalso);
                        escribirPosicionPolaca(&polaca,posicionBranch,sPosicionPolaca);
                falsosADesapilar--;
                }
                //apilo nuevamente el salto del BI anterior, solo quiero desapilar el de la condicion
                apilar(&pilaFalso,posAux);

        }
                bloqueTemasComunesYEspeciales ENDIF{
                int posicionBranch;
                char posEndIf[25];
                //salto por falso
                sprintf(posEndIf,"%d",insertarPolaca(&polaca,"ENDIF"));
                if(!pilaVacia(&pilaFalso)){
                        posicionBranch = desapilar(&pilaFalso);
                        escribirPosicionPolaca(&polaca,posicionBranch,posEndIf);
                        }
                //actualizamos la cantidad de falsos que tenia el if anterior
                cantFalsos = vecFalsosAnidados[cantCliclosAnidados-2];
                //reducimos la cant de cantCliclosAnidados
                cantCliclosAnidados--;
                }
                        
        | ENDIF {
                
                int posicionBranch, falsosADesapilar = (cantFalsos ==2)?2:1;
                char posEndIf[25];
                //salto por falso
                sprintf(posEndIf,"%d",insertarPolaca(&polaca,"ENDIF"));
                while(!pilaVacia(&pilaFalso)&& falsosADesapilar>=0){
                posicionBranch = desapilar(&pilaFalso);
                escribirPosicionPolaca(&polaca,posicionBranch,posEndIf);
                falsosADesapilar--;
                }
                //actualizamos la cantidad de falsos que tenia el if anterior
                cantFalsos = vecFalsosAnidados[cantCliclosAnidados-2];
                //reducimos la cant de cantCliclosAnidados
                cantCliclosAnidados--;
        }
;


condicion: comparacion   { insertarPolaca(&polaca,"CMP"); insertarPolaca(&polaca,comp) ;cantFalsos++; apilar(&pilaFalso,insertarPolaca(&polaca,"")); cantComparaciones++}                       
           | condicion operador{
                   char* pos;
                   int iPosicion;
                   //Tratamiento especial por ser OR
                   if(!strcmp(operador,"OR") && cantComparaciones==1){
                            invertir_salto(comp);
                            iPosicion = desapilar(&pilaFalso);
                            cantFalsos--;  
                            apilar(&pilaVerdadero,iPosicion);
                        escribirPosicionPolaca(&polaca,posicionPolaca-2,comp);
                   }

           } comparacion     
                {
                     insertarPolaca(&polaca,"CMP"); insertarPolaca(&polaca,comp);
                     apilar(&pilaFalso,insertarPolaca(&polaca,""));
                     cantFalsos++; 
                }
           |OP_NOT{ invertir_salto(comp);} comparacion                 
           ;

operador: OP_OR  {strcpy(operador, "OR");   strcpy(tipoDatoActual,"");  } 
        | OP_AND {strcpy(operador,"AND");  strcpy(tipoDatoActual,"");  }
;
comparacion: expresion comparador expresion                     
            | P_A expresion comparador expresion P_C   
            ;

comparador: OP_MAYOR {strcpy(comp, "JNA");}
        | OP_MENOR {strcpy(comp, "JAE");}
        | OP_MAYORIGUAL {strcpy(comp,"JB");}
        | OP_MENORIGUAL {strcpy(comp, "JA");}
        | OP_DISTINTO {strcpy(comp, "JE");}
        | OP_IGUAL {strcpy(comp, "JNE");}
        ;

expresion: termino OP_SUM expresion {insertarPolaca(&polaca,"OP_SUM"); }
         | termino OP_RES expresion {insertarPolaca(&polaca,"OP_RES"); }
         | termino                              
          ;

termino: factor OP_DIV termino      { insertarPolaca(&polaca,"OP_DIV");  }
        | factor OP_MULT termino    { insertarPolaca(&polaca,"OP_MULT"); }
        | factor
        ;
        

factor: ID                { 

                        if(!strcmp(tipoDatoActual ,"")){

                              strcpy(tipoDatoActual,obtenerTipoDeDato(yylval.str_val));  
                        }else{

                                validarDeclaracionID(yylval.str_val);  
                                char sTipoVariable[50];

                                strcpy(sTipoVariable, obtenerTipoDeDato(yylval.str_val));
                                
                               if(!strcmp(tipoDatoActual,"Float")){
                                        if(strcmp(sTipoVariable,"Integer") && strcmp(sTipoVariable,"Float")){
                                                printf("Se espera dato del tipo Float o Integer y recibe tipo de dato %s\n",sTipoVariable);
                                                return yyerror();   
                                        }
                                }
                                else if(strcmp(sTipoVariable,tipoDatoActual)){
                                        printf("Se espera dato del tipo %s y recibe tipo de dato %s\n",tipoDatoActual,sTipoVariable);
                                        return yyerror();   
                                }
                               
                                
                        }

                         insertarPolaca(&polaca,yylval.str_val);   }
  
        | CONST_INT    { 

                         if(!strcmp(tipoDatoActual ,"")){

                             
                        }else{
                
                        if(strcmp(tipoDatoActual,"Integer") && strcmp(tipoDatoActual,"Float")){
                                printf("Se espera dato del tipo %s y recibe tipo de dato %s\n",tipoDatoActual,"Integer");
                                return yyerror();
                         }  

                        }
                         insertarPolaca(&polaca,yylval.str_val);
                        }

        | CONST_STR     {

                          if(!strcmp(tipoDatoActual ,"")){

                        }else{
                
                         if(strcmp(tipoDatoActual,"String")){
                                printf("Se espera dato del tipo %s y recibe tipo de dato %s\n",tipoDatoActual,"String");
                                return yyerror();
                         }  

                        }
                         insertarPolaca(&polaca,yylval.str_val);
                        }

        | CONST_REAL    { 
                           if(!strcmp(tipoDatoActual ,"")){
                        }else{

                        if(strcmp(tipoDatoActual,"Float")){
                                printf("Se espera dato del tipo %s y recibe tipo de dato %s\n",tipoDatoActual,"Float");
                                return yyerror();
                         }

                         }
                          insertarPolaca(&polaca,yylval.str_val); 
                        }
      ;

let: LET listaVarLetIzq OP_ASIG P_A listaVarLetDer P_C
    ;
 
listaVarLetIzq: ID {
                        t_infoIds infoIds;
                        strcpy(infoIds.nombre, yyval.str_val);   
                        apilarId(&pilaIds, &infoIds);                   
                }
              | ID COMA listaVarLetIzq {
                         t_infoIds infoIds;
                        strcpy(infoIds.nombre, yyval.str_val);   
                        apilarId(&pilaIds, &infoIds);                                                       
                }
              ;

listaVarLetDer: expresion
         {
                char* id = desapilarId(&pilaIds); 
                if(id==""){
                     printf("Numero de ids ingresados en el LET erroneos.\n");
                        yyerror();
                }
                insertarPolaca(&polaca,id); 
                insertarPolaca(&polaca,"OP_ASIG");   
               
        }
            
        | listaVarLetDer PYC expresion 
        
        {
                char* id = desapilarId(&pilaIds); 
                 if(id==""){
                        printf("Numero de ids ingresados en el LET erroneos.\n");
                         yyerror();
                }
                insertarPolaca(&polaca,id); 
                insertarPolaca(&polaca,"OP_ASIG");   

         }
              ;

bloqueDeclaracion: DEFVAR declaraciones ENDDEF 
                  ;

declaraciones: declaracion
              | declaraciones declaracion
              ;           

declaracion: tipodato OP_DOSP listavariables          
            ;

tipodato: FLOAT {tipoDato = "Float"}
        | STRING {tipoDato = "String"}
        |  INT {tipoDato = "Integer"}
        ;

listavariables: ID PYC                 
                {
                  validarPermisoDeDeclaracionID(yylval.str_val);
                  strcpy(arrayVariables[indice].nombreVariable,yylval.str_val);  
                  strcpy(arrayVariables[indice].tipoVariable,tipoDato);  
                  indice++;    
                  nuevoSimbolo(tipoDato,"--",(tipoDato=="String")?strlen(yylval.str_val):0);
                }
              | listavariables ID PYC {
                  nuevoSimbolo(tipoDato,"--",(tipoDato=="String")?strlen(yylval.str_val):0);
                  strcpy(arrayVariables[indice].nombreVariable,yylval.str_val);  
                  strcpy(arrayVariables[indice].tipoVariable,tipoDato);  
                  indice++;    
                  }
              ;

entrada: GET ID 
        {
                insertarPolaca(&polaca,yylval.str_val);
                insertarPolaca(&polaca,"GET");
        }  
        ;

salida: DISPLAY factor 
        {
                insertarPolaca(&polaca,"DISPLAY");
        }
        ;

%%

int main(int argc,char *argv[])
{
        crearPila(&pilaVerdadero);
        crearPila(&pilaFalso);
        crearTS(&TS);
        crearPilaIds(&pilaIds);
        crearPolaca(&polaca);
        if ((yyin = fopen(argv[1], "rt")) == NULL)
        {
                printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
        }
        else
        {
                yyparse();
           
        }
        fclose(yyin);
        guardarArchivoPolaca(&polaca);
        //ññenamos arrays para codigo usuario assembler
        llenarVectorOperadores(vectorOperadores);
        llenarVectorPalabrasReservadas(vectorPalabrasReservadas);
        //generamos assembler
        generarAsm(&TS);
        liberarPolaca(&polaca);
        liberarTS(&TS);
        return 0;
}
int yyerror(void)
     {
       printf("Syntax Error\n");
	 system ("Pause");
	 exit (1);
     }



//////////////////////////////////////////////// FUNCIONES  /////////////////////////////////////////////////////////////////////////////////
///////////////////////// PILA
void crearPila(t_pila* pila){
        pila = NULL;
}

int apilar(t_pila* pila,const int iPosicion)
{       
    t_nodoPila *nuevoNodo=(t_nodoPila*) malloc(sizeof(t_nodoPila));
    if(nuevoNodo==NULL){
        return(0); //Sin_memoria
    }
    nuevoNodo->info.posicion=iPosicion;
    nuevoNodo->psig=*pila;
    *pila=nuevoNodo;
    return(1);
}

int desapilar(t_pila *pila)
{   
    t_nodoPila *aux;
    int iPosicion ;
    if(*pila==NULL)
        return 0;
    aux=*pila;
    iPosicion=(*pila)->info.posicion ;
    *pila=(*pila)->psig; 
    free(aux); 
    return iPosicion; 
}
void VaciarPila(t_pila* pila){
         pila = NULL;
}

int pilaVacia(t_pila* ppila){
        return !(*ppila);
}
///////////////////////// PILA IDs
void crearPilaIds(t_pilaIds* pilaIds){
        pilaIds = NULL;
}

int apilarId(t_pilaIds* pilaIds,const t_infoIds* infoPilaIds)
{   t_nodoPilaIds *nuevoNodo=(t_nodoPilaIds*) malloc(sizeof(t_nodoPilaIds));
    if(nuevoNodo==NULL)
        return(0); //Sin_memoria

    strcpy(nuevoNodo->infoIds.nombre,infoPilaIds->nombre);
          nuevoNodo->psig=*pilaIds;
    *pilaIds=nuevoNodo;
    return(1);
}

char * desapilarId(t_pilaIds *pilaIds)
{ 
    t_nodoPilaIds *aux;
    char * infoPilaIds;
    
    if(*pilaIds==NULL){
         return NULL;
    }

    aux=*pilaIds;
    strcpy(infoPilaIds,(*pilaIds)->infoIds.nombre);

    *pilaIds=(*pilaIds)->psig; 
    free(aux); 
        
        
    return infoPilaIds; 
}

void mostrarPilaIDs(t_pilaIds* pilaIds)
{

        while(*pilaIds){
          *pilaIds=(*pilaIds)->psig; 
        }
         
}
//////////////////////////PILA OPERANDOS
void crearPilaOperandos(t_pilaOperandos* pilaOperandos){
        pilaOperandos = NULL;
}

int apilarOperando(t_pilaOperandos* pilaOperandos,char nombreOperando[30])
{   t_nodoPilaOperandos *nuevoNodo=(t_nodoPilaOperandos*) malloc(sizeof(t_nodoPilaOperandos));
    if(nuevoNodo==NULL)
        return(0); //Sin_memoria

    strcpy(nuevoNodo->infoOperandos.nombre,nombreOperando);
    nuevoNodo->psig=*pilaOperandos;
    *pilaOperandos=nuevoNodo;
  
    return(1);
}

char* desapilarOperando(t_pilaOperandos *pilaOperandos)
{ 
    t_nodoPilaOperandos *aux;
    char * nombreOperando;
    
    if(*pilaOperandos==NULL){
         return NULL;
    }

    aux=*pilaOperandos;
    strcpy(nombreOperando,(*pilaOperandos)->infoOperandos.nombre);

    *pilaOperandos=(*pilaOperandos)->psig; 
    free(aux); 
        

    return nombreOperando; 
}

int pilaOperandoVacia(t_pilaOperandos* ppilaOperando){
        return !(*ppilaOperando);
}
///////////////////////// POLACA

void crearPolaca(t_polaca* ppolaca){

        *ppolaca = NULL;
}

int insertarPolaca(t_polaca* ppolaca,char *contenido)
{
        t_nodoPolaca* nuevoNodo = (t_nodoPolaca*)malloc(sizeof(t_nodoPolaca));
        if(!nuevoNodo){
                return 0;
        }
 
        strcpy(nuevoNodo->info.contenido,contenido);
        nuevoNodo->info.posicion=posicionPolaca++;
        nuevoNodo->psig=NULL;

        while( *ppolaca)
        {            
                ppolaca=&(*ppolaca)->psig;     
        }
        
        *ppolaca=nuevoNodo;        
        return nuevoNodo->info.posicion;
}

char* leerPosicionPolaca(t_polaca* ppolaca, int posicion){
        char* contenido;
        while(*ppolaca && (*ppolaca)->info.posicion < posicion){
                ppolaca = &(*ppolaca)->psig;
        }
        if(*ppolaca &&  (*ppolaca)->info.posicion == posicion){
                contenido = (char*) malloc(sizeof((*ppolaca)->info.contenido));
                contenido = (*ppolaca)->info.contenido;
                return contenido;
        }
        return NULL;
}

int escribirPosicionPolaca(t_polaca* ppolaca,int posicion, char *contenido) //insertar en polaca y poner pos actual 
	{
	        t_nodoPolaca* aux;
		aux=*ppolaca;
	        while(aux!=NULL && aux->info.posicion<posicion){
	    	        aux=aux->psig;
	        }	    
                if(aux && aux->info.posicion==posicion){
                        strcpy(aux->info.contenido,contenido);
                        return 1;
                }
	    return 0;
	}


void guardarArchivoPolaca(t_polaca *ppolaca){
		FILE*pint=fopen("intermedia.txt","w+");
		t_nodoPolaca* aux;
                aux = *ppolaca;
		if(!pint){
			printf("Error al crear el archivo intermedia.txt\n");
			return;
		}
		while(aux)
	    {
	        fprintf(pint, "%s\n",aux->info.contenido);
	        aux=aux->psig;
	    }

		fclose(pint);
	}
void liberarPolaca(t_polaca *ppolaca){
	t_nodoPolaca* nuevoNodo;	
	while(*ppolaca)
        {
        nuevoNodo=*ppolaca;
        *ppolaca=(*ppolaca)->psig;
        free(nuevoNodo);
        }
}
///////////////////////// UTILES
void validarDeclaracionID(char * nombreID){
        
    int i;
    int iExiste = 0;
    for(i=0;i<indice;i++)
    {
        if ( strcmp(arrayVariables[i].nombreVariable,nombreID) == 0)
        {
                iExiste = 1;
        }
    }

    if (iExiste == 0){
        printf("La variable %s no esta declarada\n",nombreID);
        yyerror();
    }
    
}

char * obtenerTipoDeDato(char* nombreID){
        
         int i;

    for(i=0;i<indice;i++)
    {
       if ( strcmp(arrayVariables[i].nombreVariable,nombreID) == 0)
        {
               return arrayVariables[i].tipoVariable;
        }
    }
   

}
void validarPermisoDeDeclaracionID(char * nombreID){   
        int i;
        int iExiste = 0;
        for(i=0;i<indice;i++)
        {
                if ( strcmp(arrayVariables[i].nombreVariable,nombreID) == 0)
                {
                        iExiste = 1;
                }
        }
        if (iExiste != 0){
                printf("La variable %s ya esta declarada\n",nombreID);
                yyerror();
        }
}
void mostrarArrayVariables(t_variables* vec){
        
         int i;

    for(i=0;i<indice;i++)
    {
         printf("variable: %s \t",vec[i].nombreVariable);
         printf("tipovariable: %s \t",vec[i].tipoVariable);
         printf("\n");
    }
   

}

char* invertir_salto(char* comp){
                if(!strcmp("JNA",comp))
                strcpy(comp,"JA");
                else if(!strcmp("JAE",comp))
                strcpy(comp,"JB");
                else if(!strcmp("JB",comp))
                strcpy(comp,"JAE");
                else if(!strcmp("JA",comp))
                strcpy(comp,"JNA");
                else if(!strcmp("JE",comp))
                strcpy(comp,"JNE");
                else if(!strcmp("JNE",comp))
                strcpy(comp,"JE");

        return comp;
}


///////////////////////// TABLA DE SIMBOLOS
int nuevoSimbolo(char* tipoDato,char valorString[],int longitud){
  FILE *tablaSimbolos = fopen("ts.txt","rw");
  char lineaescrita[100];
  t_dato_TS datoTs ;
  char valorBuscado[100];
  char linealeida[100];
  char *lineasiguiente;
  int encontro = 0;
  int i = 0;
  sprintf(lineaescrita, (longitud != 0)? 
          "%s\t\t%s\t\t%s\t\t%d":
          "%s\t\t%s\t\t%s\t\t--",
          yylval.str_val,tipoDato,valorString,longitud); //nombre-tipo de dato-valor-longitud
//llenamos dato para TS
strcpy(datoTs.nombre, yylval.str_val);
strcpy(datoTs.tipo,tipoDato);
datoTs.longitud = longitud;
strcpy(datoTs.valor,valorString);


insertarEnTS(&TS,&datoTs);

  lineasiguiente = fgets(linealeida,100,tablaSimbolos);
  while(lineasiguiente  && !encontro){
	  strcpy(valorBuscado,lineaescrita);
	  strcat(valorBuscado,"\n");
          encontro = !strcmp(valorBuscado,linealeida);
	  lineasiguiente = fgets(linealeida,100,tablaSimbolos);
  }
  fclose(tablaSimbolos);
  tablaSimbolos = fopen("ts.txt","a");
  if(!encontro){
    fprintf(tablaSimbolos,"%s\n",lineaescrita);
  }
  fclose(tablaSimbolos);
}

int buscarEnTS(){
  FILE *tablaSimbolos = fopen("ts.txt","rw");
  

  fclose(tablaSimbolos);
}

int insertarEnTS(t_TS* ts,t_dato_TS* dato){
t_nodo_TS* nuevoNodo = (t_nodo_TS*)malloc(sizeof(t_nodo_TS));
        if(!nuevoNodo){
                return 0;
        }
        //insertamos simbolo
        strcpy(nuevoNodo->dato.nombre,dato->nombre);
        strcpy(nuevoNodo->dato.tipo ,dato->tipo);
        strcpy(nuevoNodo->dato.valor,dato->valor);
        nuevoNodo->dato.longitud = dato->longitud;
        nuevoNodo->sig=NULL;


        while( *ts)
        {            
                ts=&(*ts)->sig;     
        }       
        
        *ts=nuevoNodo;        
        return 1;
}

void crearTS(t_TS * ts){
        *ts = NULL;
}

void liberarTS(t_TS* ts){
        t_nodo_TS* nuevoNodo;	
        while(*ts)
        {
        nuevoNodo=*ts;
        *ts=(*ts)->sig;
        free(nuevoNodo);
        }
}

char * buscarTipoDeDatoEnTS(t_TS* ts,char* nombreID){
        
        while(*ts){
                
          if ( strcmp((*ts)->dato.nombre,nombreID) == 0)
          {
                 return (*ts)->dato.tipo;
          }
           ts=&(*ts)->sig;    
        }
        return "0";
}
///////////////////////////ASSEMBLER
void llenarVectorOperadores(t_operador vecOperadores[30]){
      strcpy(vecOperadores[0].nombreOperador ,"OP_SUM");
      strcpy(vecOperadores[1].nombreOperador ,"OP_MULT");
      strcpy(vecOperadores[2].nombreOperador ,"OP_DIV");
      strcpy(vecOperadores[3].nombreOperador, "OP_RES");
      strcpy(vecOperadores[4].nombreOperador, "OP_ASIG");

}

void llenarVectorPalabrasReservadas(t_palabraReservada vectorPalabrasReservadas[30]){
      strcpy(vectorPalabrasReservadas[0].nombrePalabraReservada ,"CMP");
      strcpy(vectorPalabrasReservadas[1].nombrePalabraReservada ,"JNA");
      strcpy(vectorPalabrasReservadas[2].nombrePalabraReservada ,"JA");
      strcpy(vectorPalabrasReservadas[3].nombrePalabraReservada, "JB");
      strcpy(vectorPalabrasReservadas[4].nombrePalabraReservada, "JE");
      strcpy(vectorPalabrasReservadas[5].nombrePalabraReservada, "JNE");
      strcpy(vectorPalabrasReservadas[6].nombrePalabraReservada, "JMP");
      strcpy(vectorPalabrasReservadas[7].nombrePalabraReservada ,"ENDIF");
      strcpy(vectorPalabrasReservadas[8].nombrePalabraReservada ,"WHILE");
      strcpy(vectorPalabrasReservadas[9].nombrePalabraReservada, "JAE");
      strcpy(vectorPalabrasReservadas[10].nombrePalabraReservada, "THEN");
      strcpy(vectorPalabrasReservadas[11].nombrePalabraReservada, "ELSE");
      strcpy(vectorPalabrasReservadas[12].nombrePalabraReservada, "ENDW");
      strcpy(vectorPalabrasReservadas[13].nombrePalabraReservada, "THENW");
      strcpy(vectorPalabrasReservadas[14].nombrePalabraReservada, "GET");
      strcpy(vectorPalabrasReservadas[15].nombrePalabraReservada, "DISPLAY");




}

int esOperador(char valor[32]){
        int i = 0;
        for(i = 0;i<=5;i++){
                if(!strcmp(vectorOperadores[i].nombreOperador,valor))
                return 1;
        }
        return 0;
}

int esPalabraReservada(char valor[32] ){
        int i = 0;
        for(i = 0;i<=16;i++){
                if(!strcmp(vectorPalabrasReservadas[i].nombrePalabraReservada,valor))
                return 1;
        }
        return 0;
}

//CODIGO USUARIO
void generarCodigoUsuario(FILE* finalFile, t_polaca* polaca,t_TS* TS){
        t_nodoPolaca* aux;

        int tieneOperador = 0;
        t_pilaOperandos pilaOperandos;
        crearPilaOperandos(&pilaOperandos);
        aux = *polaca;

        char operando[30];
        char tipoDatoOperando[30];
        //insertar codigo de usuario en assembler
        while(aux){
                //apilamos operandos
                //vemos si no es un operador, y por ende no esta en el vector de operadores
                if(!esOperador(aux->info.contenido)){
                        if(!esPalabraReservada(aux->info.contenido)){
                                apilarOperando(&pilaOperandos,aux->info.contenido);
                        }
                        else{ //si no lo esta, vemos si no es una palabra reservada como cmp o los branchs
                                if(!strcmp(aux->info.contenido,"CMP")){
                                        //si es comparador desapilo 2
                                        printf("\n\n");
                                        fprintf(finalFile,"FLD %s\n",desapilarOperando(&pilaOperandos));
                                        fprintf(finalFile,"FLD %s\n",desapilarOperando(&pilaOperandos));
                                        fprintf(finalFile,"FXCH \n");
                                        fprintf(finalFile,"FCOM \n");   
                                }
                                else{
                                        if(!strcmp(aux->info.contenido,"ENDIF")){
                                                fprintf(finalFile,"%s%d: \n",aux->info.contenido, contEndif++);
                                        }else if(!strcmp(aux->info.contenido,"WHILE")){
                                                fprintf(finalFile,"%s%d: \n",aux->info.contenido, contWhile++);  
                                        }else if(!strcmp(aux->info.contenido,"ELSE")){
                                                fprintf(finalFile,"%s%d: \n",aux->info.contenido, contElse++);  
                                        }else if(!strcmp(aux->info.contenido,"THEN")){
                                                fprintf(finalFile,"%s%d: \n",aux->info.contenido, contThen++);  
                                        }else if(!strcmp(aux->info.contenido,"ENDW")){
                                                fprintf(finalFile,"%s%d: \n",aux->info.contenido, contEndW++);  
                                        }else if (!strcmp(aux->info.contenido,"THENW")){
                                                fprintf(finalFile,"%s%d: \n",aux->info.contenido, contThenW++);  
                                        }else if(!strcmp(aux->info.contenido,"GET")){
                                                fprintf(finalFile,"getString %s\n",desapilarOperando(&pilaOperandos));  
                                        }else if(!strcmp(aux->info.contenido,"DISPLAY")){
                                                fprintf(finalFile,"displayString %s\n",desapilarOperando(&pilaOperandos));  
                                        }
                                        else{
                                                //si es un salto leo el siguiente valor de la polaca
                                                char salto[30];
                                                strcpy(salto, aux->info.contenido);
                                                aux=aux->psig;
                                                char palabraReservada[10];
                                                strcpy(palabraReservada, leerPosicionPolaca(polaca,atoi(aux->info.contenido)));
                                                fprintf(finalFile,"%s %s",salto,leerPosicionPolaca(polaca,atoi(aux->info.contenido)));
                                                if(!strcmp("WHILE",palabraReservada)){
                                                        contWhile--;
                                                        fprintf(finalFile, "%d\n", contWhile);
                                                }else if(!strcmp(palabraReservada,"ENDIF")){
                                                        fprintf(finalFile, "%d\n", contEndif);
                                                }else if(!strcmp(palabraReservada,"ELSE")){
                                                        fprintf(finalFile, "%d\n", contElse);
                                                }else if(!strcmp(palabraReservada,"THEN")){
                                                        fprintf(finalFile, "%d\n", contThen);
                                                }else if(!strcmp(palabraReservada,"ENDW")){
                                                        fprintf(finalFile, "%d\n", contEndW);
                                                }else if(!strcmp(palabraReservada,"THENW")){
                                                        fprintf(finalFile, "%d\n", contThenW);
                                                }

                                        }
                                }
                                
                        }
                }
                else{ 
                        //agregamos variable res para guardar respuesta de operaciones
                        strcpy(res, "@RES");
                        //si es un operador desapilo los dos apilados anteriormente

                        if(!strcmp(aux->info.contenido ,"OP_SUM")){
                             
                                //DESAPILO EL PRIMER OPERANDO Y ME FIJO EL TIPO DE DATO 
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));
                             
                                //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                 // me fijo si el cte tiene un punto, 46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");         
                                     }  
                                }
                               

                                if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }
                              
                                //DESAPILO EL SEGUNDO OPERANDO Y ME FIJO EL TIPO DE DATO 
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));


                                 //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                        // me fijo si el cte tiene un punto,  46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");           
                                     }  
                                }
                         
                                 if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }
                                fprintf(finalFile,"FADD \n");
                                fprintf(finalFile,"FSTP %s\n",res);
                                apilarOperando(&pilaOperandos,res);
                                fprintf(finalFile,"FFREE \n");
                                tieneOperador = 1;
                        }
                         if(!strcmp(aux->info.contenido ,"OP_MULT")){

                                //DESAPILO EL PRIMER OPERANDO Y ME FIJO EL TIPO DE DATO 
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));
                               
                                //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                        // me fijo si el cte tiene un punto, 46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");          
                                     }  
                                }

                                if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }
                              
                                //DESAPILO EL SEGUNDO OPERANDO Y ME FIJO EL TIPO DE DATO 
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));


                                 //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                        // me fijo si el cte tiene un punto  , 46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");           
                                     }  
                                }

                                 if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }
                            
                                fprintf(finalFile,"FMUL \n");
                                fprintf(finalFile,"FSTP %s\n",res);
                                apilarOperando(&pilaOperandos,res);
                                fprintf(finalFile,"FFREE \n");
                                tieneOperador = 1;

                        }
                         if(!strcmp(aux->info.contenido ,"OP_DIV")){
             
                                
                                //DESAPILO EL PRIMER OPERANDO Y ME FIJO EL TIPO DE DATO 
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));
                               
                                //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                 // me fijo si el cte tiene un punto, 46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");          
                                     }  
                                }

                                if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }
                              
                                //DESAPILO EL SEGUNDO OPERANDO Y ME FIJO EL TIPO DE DATO 
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));


                                 //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                        // me fijo si el cte tiene un punto  , 46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");           
                                     }  
                                }

                                 if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }
                                fprintf(finalFile,"FEXC \n");
                                fprintf(finalFile,"FDIV \n");
                                fprintf(finalFile,"FSTP %s\n",res);
                                apilarOperando(&pilaOperandos,res);
                                fprintf(finalFile,"FFREE \n");
                                tieneOperador = 1;

                        }
                         if(!strcmp(aux->info.contenido ,"OP_RES")){
                               
                                //DESAPILO EL PRIMER OPERANDO Y ME FIJO EL TIPO DE DATO 
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));
                               
                                //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                        // me fijo si el cte tiene un punto, 46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");          
                                     }  
                                }

                                if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }
                              
                                //DESAPILO EL SEGUNDO OPERANDO Y ME FIJO EL TIPO DE DATO 
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));


                                 //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                        // me fijo si el cte tiene un punto  , 46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");           
                                     }  
                                }

                                 if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }
                            
                                fprintf(finalFile,"FSUB \n");
                                fprintf(finalFile,"FSTP %s\n",res);
                                apilarOperando(&pilaOperandos,res);
                                fprintf(finalFile,"FFREE \n");
                                tieneOperador = 1;

                        }
                         if(!strcmp(aux->info.contenido , "OP_ASIG")){
                                 printf(" \n");
                                strcpy(idAsigna,desapilarOperando(&pilaOperandos));

                                if(strcmp(idAsigna,"@RES")!=0 && tieneOperador){
                                 //desapilamos el id al que se le asigna valor
                                strcpy(operando,desapilarOperando(&pilaOperandos));
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,operando));
 
                                //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                        // me fijo si el cte tiene un punto , 46 es el punto ascci
                                     if(strchr(operando,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");           
                                     }  
                                }
                                
                                if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",operando); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",operando);
                                }

                                fprintf(finalFile,"FSTP %s\n",idAsigna);
                                tieneOperador = 0;  
                                }
                                else{

                      
                                strcpy(tipoDatoOperando, buscarTipoDeDatoEnTS(TS,idAsigna));

                                //Caso de que sea una constante string 
                                if(!strcmp(tipoDatoOperando,"--")){
                                        // me fijo si el cte tiene un punto , 46 es el punto ascci
                                     if(strchr(idAsigna,46)!=NULL){
                                         strcpy(tipoDatoOperando,"Float");          
                                     }else{
                                         strcpy(tipoDatoOperando,"Integer");           
                                     }  
                                }
                                
                                if(!strcmp(tipoDatoOperando,"Integer")){
                                     fprintf(finalFile,"FILD %s\n",idAsigna); // FLOAT
                                }else{
                                     fprintf(finalFile,"FLD %s\n",idAsigna);
                                }                                        
        
                                fprintf(finalFile,"FSTP %s\n",desapilarOperando(&pilaOperandos));  
                                tieneOperador = 0;  
                                }
                                
                                
                        
                        }

                }
                
	        aux=aux->psig;
	}
}

void generarAsm(t_TS* TS){
	printf("***Generando ASM**** \n");
	FILE *finalFile = fopen("Final.asm","w");
	if(finalFile == NULL)
	{
		printf("Error al crear el archivo Final.asm");
		getchar();
		exit(0);
	}
	fprintf(finalFile, "include macros2.asm\n");
	fprintf(finalFile, "include number.asm\n");
	fprintf(finalFile,".MODEL LARGE\n");
	fprintf(finalFile,".386\n");
	fprintf(finalFile,".STACK 200h\n");
	fprintf(finalFile,".DATA\n");
	//////////////////////////////DECLARAMOS VARIABLES	
        // estructuras necesarias para recorrer la TS
	int  tipoDatoId;
        t_nodo_TS* aux;
        aux = *TS;
	
            //recorremos la Tabla de simbolos (estructura) y declaramos ids y ctes
	 while(aux)  
	{
                tipoDatoId = (!strcmp(aux->dato.tipo, "Integer"))?1:
                (!strcmp(aux->dato.tipo, "Float"))?2:
                (!strcmp(aux->dato.tipo, "String"))?3:0;
                switch(tipoDatoId){
                        case 0:
                        //Si es 0 no tiene tipo por lo tanto es una cte y guardamos valor
                                if(!atoi(aux->dato.valor))
                                        fprintf(finalFile,"%s dd \"%s\"\n",aux->dato.nombre, aux->dato.valor);  
                                else
                                        fprintf(finalFile,"%s dd %s\n",aux->dato.nombre, aux->dato.valor);         
                                break;
                        case 1: 	  
                                fprintf(finalFile,"%s dd %s\n",aux->dato.nombre, "?");         
                                break;
                        case 2:    
                                fprintf(finalFile,"%s dd %s\n",aux->dato.nombre,"?");        
                                break;
                        case 3:  
                                fprintf(finalFile,"%s dd %s\n",aux->dato.nombre,"?"); 
                                break;	
                        }
    
                aux=aux->sig;
        }
        fprintf(finalFile,"@RES dd ?");
	fprintf(finalFile,"\n.CODE \n");
	fprintf(finalFile,"mov ah, 1;\n");
	fprintf(finalFile,"int 21h ;\n");
	fprintf(finalFile,"MOV AX, 4C00h; \n");
	fprintf(finalFile,"int 21h;\n");
        //PROGRAMA DE USUARIO
        generarCodigoUsuario(finalFile, &polaca,TS);
	fprintf(finalFile,"END\n");

        ////////////////////////////////PROGRAMA DEL USUARIO

	fclose(finalFile);

} 
