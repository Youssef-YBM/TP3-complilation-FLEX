/* Exercice 1.1 a) : reconnaissance de symboles.
 * Un symbole commence par une lettre, suivie de lettres ou de chiffres.
 * Tout ce qui n'est pas reconnu (chiffres seuls, ponctuation, espaces...)
 * est recopié tel quel par la règle par défaut de Flex (ECHO).
 */

/* Pas de fonction yywrap : on s'arrête à la fin du fichier */
%option noyywrap

%%
 /* lettre suivie de zéro ou plusieurs lettres/chiffres : on l'affiche entre < > */
[a-zA-Z][a-zA-Z0-9]*    { printf("<%s> ", yytext); }
%%

/* Programme principal : lance simplement l'analyse de l'entrée standard */
int main(void)
{
    yylex();
    return 0;
}
