%option noyywrap
%%
for|while|if|else|do|int|float|char|return|void|switch|case|break  { printf("<MOT-CLE:%s> ", yytext); }
[a-zA-Z][a-zA-Z0-9]*                                              { printf("<SYMBOLE:%s> ", yytext); }
"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="                 { printf("<OPERATEUR:%s> ", yytext); }
[-+*/%=<>!&|^~]                                                   { printf("<OPERATEUR:%s> ", yytext); }
[(){}\[\];,.:]                                                    { printf("<OPERATEUR:%s> ", yytext); }
%%
int main(void)
{
    yylex();
    return 0;
}
