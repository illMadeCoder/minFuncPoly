/*
  By : Jesse Bergerstock
  Date : 02/19/2016
  Description : A minimal functional language.
*/

%lex
%%

\s+                   /**/
(\n|";")+             return 'NEWLINE'
"print"               return 'PRINT'
[0-9]+                return 'NUMBER'
[a-z]                 return 'IDENTIFIER'
"+"|"-"|"*"|"/"|"%"   return 'BI_OP'
"="                   return 'ASSIGNMENT'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex
/* precedence */
%start file
%%

/* Grammar */

file
  : statements EOF
    {return {type : "file", value : $1};}
  ;
statements
  : statement statements
    {$$ = [$1].concat($2)}
  |
  ;
statement
  : assignment NEWLINE
    {$$ = {type : "statement", value : $1};}
  ;
assignment
  : IDENTIFIER ASSIGNMENT expression
    {$$ = {type : "assignment", value : {symbol : $1, expression : $3}};}
  ;
expression
  : IDENTIFIER
    {$$ = {type : "identifier", value : $1}}
  | NUMBER
    {$$ = {type : "number", value : parseInt($1)}}
  | NUMBER BI_OP NUMBER
    {$$ = {type : "number", value : parseInt($1)+parseInt($3)}}
  ;
/*
expr
  : assignment newline expr
    {yy.syntax_tree.push({type : "expr", arg : [$1]});}
  | print newline expr
    {yy.syntax_tree.push({type : "expr", arg : [$1]});}
  |
  ;
newline
  : NEWLINE newline
  | NEWLINE
  ;
print
  : PRINT variable
    {$$ = {type : "print", arg : [$2]};}
  ;

assignment
  : id ASSIGNMENT number
    {$$ = {type : "assignment", arg : [$1,$3]};}
  ;

variable
  : id
    {$$ = $1;}
  | number
    {$$ = $1;}
  ;

id
  : IDENTIFIER
    {$$ = {type : "id", arg : [$1]};}
  ;

number
  : NUMBER
    {$$ = {type : "number", arg : [$1]};}
  ;
*/
%%
