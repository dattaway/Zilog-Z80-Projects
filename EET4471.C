#include <stdio.h>
#include <math.h>
void introduction()
{
  printf("ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป\n");
  printf("บ Duane Attaway      | Transfer Functions                         บ\n");
  printf("บ Alan Hansen        |                                            บ\n");
  printf("บ Control Systems ][ | You will be asked to enter the function    บ\n");
  printf("บ 9DA-EET447L        | G(s) and the feedback H(s).  The resultant บ\n");
  printf("บ                    | sensitivity values will be calculated      บ\n");
  printf("บ                    | and displayed.                             บ\n");
  printf("บ                    |                                            บ\n");
  printf("ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ\n");
}


void main()
{
float g,h,gtemp,gtemp2,t,ttemp,ttemp2,dg,dt,s;
char i;

  introduction();

  for(i='y';i=='y';)
  {
    printf("\n");
    printf("\n");
    printf("ENTER input G-->");
    scanf("%d",&g);
    printf("\n");
    printf("ENTER input H-->");
    scanf("%d",&h);
    printf("\n");

    gtemp=g*1.1;
    gtemp2=g*0.9;
    dg=gtemp-gtemp2;
    t=g/(1+(g*h));
    ttemp=gtemp/(1+(gtemp*h));
    ttemp2=gtemp2/(1+(gtemp2*h));
    dt=ttemp-ttemp2;
    s=(dt*g)/(dg*t);

    printf("The calculated sensitivity values are.\n\n");
    printf("      Delta T = %12e\n\n",dt);
    printf("            T\n");
    printf("           S  = %12e\n",s);
    printf("            G\n\n");
    printf("Another calculation (Y/N)\n");
  }
}
