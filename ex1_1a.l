%option noyywrap
%%
[a-zA-Z][a-zA-Z0-9]*    { printf("<%s> ", yytext); }
%%
int main(void)
{
    yylex();
    return 0;
}
