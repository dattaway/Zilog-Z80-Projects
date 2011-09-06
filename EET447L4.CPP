//
// Control Systems ][  Ruth-Horowitz Criterion
// 9DA - EET447L	Tue  05-26-1992
// Duane Attaway
// Alan Hansen
//
// This program determines the stability of an equation
// from the number of positive roots it has.
//
// The program asks for the highest order of equation,
// from which the user will be promted to enter the
// corresponding constant for each variable power.
// If an auxillary equation is then needed to determine
// the criterion, the user will be notified of such.
//
#include <iostream.h>
#include <math.h>
#include <complex.h>
#include <ctype.h>
#include <stdio.h>

#define PI 3.14159265359

int main ()
{
double z[30][30];					    //results
double sum;						    //summation
int x, xr, s, q;					    //count variables
int co_max, power, count2, countx;			    //references
int aux_count, t, ex_po, ex_po1, y, p_c, bak, bak2, root;   //variables
char p, a, g, aux_flag; 				    //'do' flags


cout << "\nAuxillary Equation (Y/N)? ";
cin >> p;
if (tolower(p) == 'y')
	aux_flag = 0; // print information later
else
	aux_flag = 2; // dont't print info
cout << "\n\nEnter Highest Power of Equation ------>";
cin >> co_max;

count2 = (co_max + 2)/2;
countx = co_max;
sum =1;

for (x=0; x<count2; x++)
	{
		cout << "\nCoefficient of s^" << countx << " -------------------->";
		cin >> z[0][x];
		if(fabs(z[0][x])<sum && z[0][x]!=0)
			sum = z[0][x];
		z[0][x+1] = 0;
		countx--;

		if ((co_max % 2 == 0) &&( x == count2 -1))
			z[1][x]=0;
		else
			{
				cout << "\nCoefficient of s^" << countx << " ----->";
				cin >> z[1][x];
				if((fabs(z[1][x])< sum)&&(z[1][x]!=0))
					sum = z[1][x];
			}
		countx--;
	}

a = 1;
sum = sum/1000;

ex_po = co_max - 1;
for(x=2; x < co_max + 1; x++)
	{
		count2 = ((co_max - x) + 2 )/2;
		ex_po--;

		for(xr=0; xr< count2; xr++)
			{
				if (z[x-1][0]==0)
					{
						if((xr!=0)&&(z[x][xr+1]==0))
							z[x][xr]=z[x-2][xr+1];
						else
							if(z[x-2][0]==0)
								z[x][xr]=z[x-2][xr+1];
							else
								z[x][xr]=((sum*z[x-2][xr+1]) - (z[x-2][0]*z[x-1][xr+1]))/sum;
					}
				else
					{
						if((xr!=0)&&(z[x-1][xr+1]==0))
							z[x][xr]=z[x-2][xr+1];
						else
							if (z[x-2][0]==0)
								z[x][xr]=z[x-1][xr+1];
							else
								z[x][xr]=((z[x-1][0]*z[x-2][xr+1])-(z[x-2][0]*z[x-1][xr+1]))/z[x-1][0];
					}
				aux_count = x;
				z[x][xr+1]=0;
			}
		for(t=0;t<count2; t++)
			{
				if(z[x][t]!=0)
					{
						p='Z';
						t=count2+3;
					}
				else
					p='G';
			}
		if(p=='G')
		{
			x=co_max+3;
			ex_po1++;
			cout << "\nAuxillary Equation from Characteristic:\n\n";
			for(t=0;t<count2+1;t++)
			{
				cout << z[aux_count-1][t] << " s^" << ex_po1 << " ,";
				ex_po1--;
        ex_po1--;
			}
			a='E';
		}
	}

cout << "\n\n컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴";
p_c=co_max;
cout << 	"\nPower                                                                   ";
for(x=0;x<co_max+1;x++)
{
	count2=(((co_max-1)-x)+2)/2;
	cout << "\n\ns^" << p_c << "--";
	for(xr=0;xr<count2+1;xr++)
	{
		if((x>ex_po+1)&&(a=='E'))
			printf (" %14.7", 0);
		else
			printf (" %14.7lg", z[x][xr]);
	}
	p_c--;
}
cout << "\n\n컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴";
if(a=='E')
	cout << "\nAuxillary Equation:";

if(a==1)
{
	if(z[0][0]<0)
		bak=1;
	else
		bak=0;

	root=0;
	for(t=0;t<co_max+1;t++)
	{
		if(z[t][0]<0)
			bak2=1;
		else
			bak2=0;
		if(bak!=bak2)
			root++;
		bak=bak2;
	}
	if(aux_flag==0)
		cout << "\nSystem may be Marginally Stable";
	cout << "\nThere are " << root << " positive roots in this ";
	if((root!=0)&&(aux_flag!=0))
		cout << "unstable";
	else
		if((root==0)&&(aux_flag!=0))
			cout << "stable";
		else
			if((aux_flag==0)&&(root==0))
				cout << "marginally stable";
			else
				cout << "unstable";
	cout << " system.";
}
}

