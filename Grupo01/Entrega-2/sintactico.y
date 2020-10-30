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
char tipoDatoActual[50] = "";

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
		char nombreVaribale[30];
		char tipoVariable[30];

	}t_variables;

/////////////////DECLARACION FUNCIONES
int insertarEnTS(char[],char[],int);
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


void mostrarArrayVariables(t_variables* );
void validarDeclaracionID(char *);
char * obtenerTipoDeDato(char *);


//declaracion de variables
t_pila pila;
t_polaca polaca;
char comp[3];
char op[3];
char idValor[25];
int cantComparaciones=0;

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
                apilar(&pilaVerdadero,insertarPolaca(&polaca,"ET"));
                cantCliclosAnidados++; 
                //guardamos la cantidad de saltos por falso que tiene el if anidado anterior
                if(cantCliclosAnidados>1){ 
                        vecFalsosAnidados[cantCliclosAnidados-2] = cantFalsos;
                        cantFalsos = 0;
                        }
                }  
        P_A condicion{
                 cantComparaciones = 0;
        } P_C {
                int posicionBranch=0;
                char sPosicionPolaca [25];
                sprintf(sPosicionPolaca,"%d",posicionPolaca);
                 if(!pilaVacia(&pilaVerdadero)){
                        posicionBranch = desapilar(&pilaVerdadero); 
                        escribirPosicionPolaca(&polaca,posicionBranch,sPosicionPolaca);
                }
        }  
        bloqueTemasComunesYEspeciales ENDW {
        int posicionInicial, posicionBranch, falsosADesapilar = (cantFalsos ==2)?1:0;
        char posFalso[25];
        char posInicio[25];
        if(!pilaVacia(&pilaVerdadero)){
                posicionInicial = desapilar(&pilaVerdadero); 
                sprintf(posInicio,"%d",posicionInicial);
                insertarPolaca(&polaca,"BI");
                escribirPosicionPolaca(&polaca,insertarPolaca(&polaca,""),posInicio);
        }
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
                insertarPolaca(&polaca,"BI");
                apilar(&pilaVerdadero,insertarPolaca(&polaca,""));
        } 
        COMA{
                //desapilar pilaFalso.
                int posicionBranch;
                char posActual[25];
                sprintf(posActual,"%d",posicionPolaca);
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
                int iPosicion;
                char posThen[25];
                sprintf(posThen,"%d",posicionPolaca);
                if(!pilaVacia(&pilaVerdadero)){
                iPosicion = desapilar(&pilaVerdadero); 
                escribirPosicionPolaca(&polaca,iPosicion,posThen);
                }
        }
        bloqueTemasComunesYEspeciales{
                insertarPolaca(&polaca,"BI");
                apilar(&pilaFalso,insertarPolaca(&polaca,""));
        }
        ;

finSeleccion: ELSE{
                int posicionBranch, falsosADesapilar = (cantFalsos ==2)?1:0, posAux;
                char sPosicionPolaca[25];
                sprintf(sPosicionPolaca,"%d",posicionPolaca);
                //desapilo salto de BI
                posAux = desapilar(&pilaFalso);
                while(!pilaVacia(&pilaFalso) && falsosADesapilar>=0){
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

comparador: OP_MAYOR {strcpy(comp, "BLE");}
        | OP_MENOR {strcpy(comp, "BGE");}
        | OP_MAYORIGUAL {strcpy(comp,"BLT");}
        | OP_MENORIGUAL {strcpy(comp, "BGT");}
        | OP_DISTINTO {strcpy(comp, "BEQ");}
        | OP_IGUAL {strcpy(comp, "BNE");}
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
                                
                                if (strcmp(sTipoVariable,tipoDatoActual)){
                                        printf("Se espera dato del tipo %s y recibe tipo de dato %s\n",tipoDatoActual,sTipoVariable);
                                        return yyerror();   
                                }
                               
                                
                        }

                         insertarPolaca(&polaca,yylval.str_val);   }
  
        | CONST_INT    { 

                         if(!strcmp(tipoDatoActual ,"")){

                              strcpy(tipoDatoActual,obtenerTipoDeDato(yylval.str_val));  
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

                              strcpy(tipoDatoActual,obtenerTipoDeDato(yylval.str_val));  
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

                              strcpy(tipoDatoActual,obtenerTipoDeDato(yylval.str_val));  
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
                  strcpy(arrayVariables[indice].nombreVaribale,yylval.str_val);  
                  strcpy(arrayVariables[indice].tipoVariable,tipoDato);  
                  indice++;    
                  nuevoSimbolo(tipoDato,"--",(tipoDato=="String")?strlen(yylval.str_val):0);
                }
              | listavariables ID PYC {
                  nuevoSimbolo(tipoDato,"--",(tipoDato=="String")?strlen(yylval.str_val):0);
                  strcpy(arrayVariables[indice].nombreVaribale,yylval.str_val);  
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
        crearPila(&pilaFalso);
        crearPila(&pilaVerdadero);
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
        // mostrarArrayVariables(arrayVariables);
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
         return (*pilaIds)->infoIds.nombre;
    }

    aux=*pilaIds;
    infoPilaIds=(*pilaIds)->infoIds.nombre;

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


///////////////////////// POLACA

void crearPolaca(t_polaca* ppolaca){

        *ppolaca = NULL;
}

int insertarPolaca(t_polaca* ppolaca,char *contenido)
{
        t_nodoPolaca* nuevoNodo = (t_nodoPolaca*)malloc(sizeof(t_nodoPolaca));
        if(!nuevoNodo){
                return 1;
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

int escribirPosicionPolaca(t_polaca* ppolaca,int posicion, char *contenido) //insertar en polaca y poner pos actual 
	{
	        t_nodoPolaca* aux;
		aux=*ppolaca;
	    while(aux!=NULL && aux->info.posicion<=posicion){
	    	aux=aux->psig;
                    if(aux->info.posicion==posicion){
                        strcpy(aux->info.contenido,contenido);
                        return 1;
                    }
	    }	    
	    return 0;
	}


void guardarArchivoPolaca(t_polaca *ppolaca){
		FILE*pint=fopen("intermedia.txt","w+");
		t_nodoPolaca* nuevoNodo;
		if(!pint){
			printf("Error al crear el archivo intermedia.txt\n");
			return;
		}
		while(*ppolaca)
	    {
	        nuevoNodo=*ppolaca;
	        fprintf(pint, "%s\n",nuevoNodo->info.contenido);
	        *ppolaca=(*ppolaca)->psig;
	        free(nuevoNodo);
	    }
		fclose(pint);
	}
   
///////////////////////// UTILES
void validarDeclaracionID(char * nombreID){
        
    int i;
    int iExiste = 0;
    for(i=0;i<indice;i++)
    {
        if ( strcmp(arrayVariables[i].nombreVaribale,nombreID) == 0)
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
       if ( strcmp(arrayVariables[i].nombreVaribale,nombreID) == 0)
        {
               return arrayVariables[i].tipoVariable;
        }
    }
   

}

void mostrarArrayVariables(t_variables* vec){
        
         int i;

    for(i=0;i<indice;i++)
    {
         printf("variable: %s \t",vec[i].nombreVaribale);
         printf("tipovariable: %s \t",vec[i].tipoVariable);
         printf("\n");
    }
   

}

char* invertir_salto(char* comp){
                if(!strcmp("BLE",comp))
                strcpy(comp,"BGT");
                else if(!strcmp("BGE",comp))
                strcpy(comp,"BLT");
                else if(!strcmp("BLT",comp))
                strcpy(comp,"BGE");
                else if(!strcmp("BGT",comp))
                strcpy(comp,"BLE");
                else if(!strcmp("BEQ",comp))
                strcpy(comp,"BNE");
                else if(!strcmp("BNE",comp))
                strcpy(comp,"BEQ");

        return comp;
}

///////////////////////// TABLA DE SIMBOLOS
int nuevoSimbolo(char* tipoDato,char valorString[],int longitud){
  FILE *tablasimbolos = fopen("ts.txt","rw");
  char lineaescrita[100];
  char valorBuscado[100];
  char linealeida[100];
  char *lineasiguiente;
  int encontro = 0;
  int i = 0;
  sprintf(lineaescrita, (longitud != 0)? 
          "%s\t\t%s\t\t%s\t\t%d":
          "%s\t\t%s\t\t%s\t\t--",
          yylval.str_val,tipoDato,valorString,longitud); //nombre-tipo de dato-valor-longitud

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
int buscarEnTS(){
  FILE *tablasimbolos = fopen("ts.txt","rw");
  

  fclose(tablasimbolos);
}
