/*
  By : Jesse Bergerstock
  Date : 02/19/2016
  Description : A minimal functional language grammar.
*/

%lex
%%

\s+                   /**/
(\n|";")+             return 'NEWLINE'
"print"               return 'PRINT'
"dump"                return 'DUMP'
"func"                return 'FUNCTION_DEFINE'
"("                   return 'LEFT_PAR'
")"                   return 'RIGHT_PAR'
","                   return 'COMMA'
"::"                  return 'SIGNATURE'
"->"                  return 'NEXT_PARAMETER'
[0-9]+                return 'NUMBER'
[a-zA-Z]+                return 'IDENTIFIER'
"+"|"-"|"*"|"/"|"%"   return 'BI_OP'
"="                   return 'ASSIGNMENT'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex
/* precedence */
%right NEXT_PARAMETER
%left IDENTIFIER

%start program
%%

/* Grammar */

program
  : statements EOF
    {return {type : "program", statements : $1};}
  ;
statements
  : statement statements
    {$$ = [$1].concat($2)}
  | statement
    {$$ = [$1]}
  ;
statement
  : assignment NEWLINE
  | function_define NEWLINE
  | print NEWLINE
  | dump NEWLINE
  ;
print
  : PRINT expression
    {$$ = {type : "print", expression : $2, string : ""}}
  | PRINT STRING expression
    {$$ = {type : "print", expression : $3, string : $2}}
  ;
dump
  : DUMP
    {$$ = {type : "dump"}}
  ;
assignment
  : IDENTIFIER ASSIGNMENT expression
    {$$ = {type : "assignment", symbol : $1, expression : $3}}
  ;
expression
  : IDENTIFIER
    {$$ = {type : "identifier", symbol : $1}}
  | NUMBER
    {$$ = {type : "number", value : parseInt($1)}}
  | IDENTIFIER arguments
    {$$ = {type : "function_call", symbol : $1, arguments : $2}}
  ;
arguments
  : LEFT_PAR RIGHT_PAR
    {$$ = []}
  | LEFT_PAR expression RIGHT_PAR
    {$$ = [$2]}
  | LEFT_PAR expression argument
    {$$ = [$2].concat($3)}
  ;
argument
  : COMMA expression argument
    {$$ = [$2].concat($3)}
  | COMMA expression RIGHT_PAR
    {$$ = [$2]}
  ;
function_define
  : FUNCTION_DEFINE IDENTIFIER SIGNATURE parameters expression
    {$$ = {type : "function_define", symbol : $2, parameters : $4, expression : $5}}
  ;
parameters
  : IDENTIFIER NEXT_PARAMETER parameter
    {$$ = [$1].concat($3)}
  | NEXT_PARAMETER
    {$$ = []}
  ;
parameter
  : IDENTIFIER NEXT_PARAMETER parameter
    {$$ = [$1].concat($3)}
  | IDENTIFIER NEXT_PARAMETER
    {$$ = [$1]}
  ;
%%
