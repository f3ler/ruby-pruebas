/*Programa creado por Juan Carlos Albarr n Flores
para carlos0_0@yahoo.com.mx
Instituto Politecnico Nacional
Ingenieria en Comunicaciones y Electronica
Agradecimientos a Marleni Valencia Estrello 
All rights reserved
*/


#include <stdio.h>
#include <math.h>
main()
{
 long a,b,producto,mcm,dividiendo,restando1=1;
 clrscr();
 gotoxy(4,7);
 printf("Programa que calcula el minimo Comun multiplo de 2 numeros enteros Reales");
 gotoxy(13,9);
 printf("Introduzca dos numeros enteros separados por comas: ");
 scanf("%ld,%ld",&a,&b);
 producto=a*b;
 if (a<b) {dividiendo=a; a=b; b=dividiendo;}
 while (restando1>0) {
	dividiendo=a/b;
	restando1=a%b;
	a=b;
	b=restando1;
  }
 mcm=producto/a;
 gotoxy(19,14);
 printf ("El Minimo comun multiplo es: %ld",mcm);
 getch();
}
