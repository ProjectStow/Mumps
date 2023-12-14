Test ;Test routine
 W !,"Hello World"
 Quit
Sub1 New A For A=1:1:10 D  
 .W !,A
 Quit
Sub2(L) ;
 New A
 For A=1:1:10 W !,A
 Quit
Sub3(L,B) New (L,B),B:$H>10
 For A=1:1:10 W !,A
 Quit