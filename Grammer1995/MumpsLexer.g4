

CIRCUMFLEX:
 '^';

RIGHTPAREN:
 ')';

LEFTPAREN:
 '(';

COMMA:
 ',';

SPACE:
 ' ';

PLUS:
 '+';

NAME:
 ('a' .. 'z' | 'A' .. 'Z' | '%')  ('a' .. 'z' | 'A' .. 'Z' | '0' .. '9')*;



STRING_LITERAL:
     '"' ('""' | ~'"')* '"';


NUMBER:
     ('0' .. '9')+ ('.' ('0' .. '9')+)?;


COMMENT
    : ';' ~[\r\n]*
    ;


fragment A : [aA]; // match either an 'a' or 'A'
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];
