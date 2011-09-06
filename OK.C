program SSError;

(****************************************************************************)
(*                                                                          *)
(*         Open and Closed Loop Steady State Error calculation program      *)
(*                                                                          *)
(*                            BY                                            *)
(*                                                                          *)
(*                       Alan Hansen                                        *)
(*                           &                                              *)
(*                       Dwane Attaway                                      *)
(*                                                                          *)
(*                          4-11-92                                         *)
(*                                                                          *)
(****************************************************************************)



(*
This program requires the programer to enter the poles and zeros of the
equations to be used. The program will automaticaly find the conjugate
of a complex pole or zero. The program is limited to 40 poles ar zeros. The
program does require the used of a EGA or VGA display capable of 50 lines
by 80 collums.                                                              *)



{$n+}
uses crt;
(* set dimentions of the arrays*)
const
     numentr=41;
     complex=2;

type
    line=array[1..complex]of real;
    numarray=array[1..numentr]of line;

var
   poles,zeros :numarray;
   x,y : integer;
   z,p,g : double;
   des : char;

begin
     repeat
          clrscr;


          (* jump in and get to pole information*)
          repeat
                write ('Number of poles: ');
                readln(poles[1,1]);
          until poles[1,1] <= 40;

          writeln;
          write ('Pole multiplication constant: ');
          readln(poles[1,2]);
          x := 0;
          y := 2;
          while poles[1,1]-x > 0 do

          begin
               write('Pole ',x,'--> ');
               readln(poles[y,1],poles[y,2]);
               if poles[y,2]<>0 then

                  if poles[1,1]-x-2 >= 0 then

                  begin
                     x := x+1;
                     writeln('    Pole ',x,' assumed at ',poles[y,1]:16:6,',',-poles[y,2]:16:6);
                     end
                  else

                    begin
                         writeln('ERROR too many poles entered');
                         writeln('Reenter the poles');
                         x :=0;
                         y :=1;
                    end;
               y:=y+1;
               x:=x+1;
          end;


          writeln;
          writeln;
          (*get the zero information *)


          repeat
                write ('Number of zeros: ');
                readln(zeros[1,1]);
          until zeros[1,1] <= 40;

          writeln;
          write ('Zero multiplication constant: ');
          readln(zeros[1,2]);
          x := 0;
          y := 2;
          while zeros[1,1]-x>0 do
          begin
               write('Zero ',x,'--> ');
               readln(zeros[y,1],zeros[y,2]);
               if zeros[y,2]<>0 then

                  if zeros[1,1]-x-2 >= 0 then

                  begin
                     x := x+1;
                     writeln('    Zero ',x,' assumed at ',zeros[y,1]:16:6,',',-zeros[y,2]:16:6);
                     end
                  else

                  begin
                       writeln('ERROR too many zeros entered');
                       writeln('Reenter the zeros');
                       x :=0;
                       y :=1;
                  end;
               y:=y+1;
               x:=x+1;
          end;

          (*Format data for output and start the calculation of g(0)*)
          clrscr;
          writeln('          Poles                                   Zeros');
          p:=poles[1,2];
          x:=0;
          y:=2;
          while poles[1,1]-x > 0 do

          begin
               gotoxy(1,y);
               write(poles[y,1]:12:6,' ',#241,' j',poles[y,2]:12:6);
               if poles[y,2]<>0 then

               begin
                  p:=p*(sqr(poles[y,1])+sqr(poles[y,2]));
                  x:=x+1;
                  end
               else

                  p:=p*-poles[y,1];

               x:=x+1;
               y:=y+1;
          end;

          z:=zeros[1,2];
          x:=0;
          y:=2;
          while zeros[1,1]-x > 0 do

          begin
               gotoxy(40,y);
               write(zeros[y,1]:12:6,' ',#241,' j',zeros[y,2]:12:6);
               if zeros[y,2]<>0 then

               begin
                  z:=z*(sqr(zeros[y,1])+sqr(zeros[y,2]));
                  x:=x+1;
                  end
               else

                  z:=z*-zeros[y,1];

               x:=x+1;
               y:=y+1;
          end;




          (*Calculate G(0) and the steady state errors *)
          g:=z/p;
          gotoxy(1,45);
          writeln('G(0) = ',g:16:6);
          writeln('Steady State Error (OPEN LOOP) = ',1-g:16:6);
          writeln('Steady State Error (CLOSE LOOP) = ',1/(1+g):16:6);
          writeln;


          (*do they want more?*)
          write('Another calculation (Y/N) ');
          readln(des);
     until (des = 'N') or (des = 'n');


end.