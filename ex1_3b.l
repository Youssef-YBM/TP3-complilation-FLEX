/* Exercice 1.3 b) : mots sur {a,b} commençant ou finissant par a.
 * Hypothèse : un seul mot par ligne.
 * Mot accepté : recopié suivi de "-> ACCEPTE".
 * Mot rejeté  : chaque caractère est signalé par <?x> (règle attrape-tout).
 */

%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>

/* Lit tout le fichier en mémoire :
 *  - supprime les \r (fichiers créés sous Windows)
 *  - garantit qu'il y a un \n à la fin (nécessaire pour la règle ancrée par $)
 */
static char *lire(FILE *f)
{
    size_t n = 0, cap = 1024;
    char *buf = malloc(cap);
    int c;
    while ((c = fgetc(f)) != EOF) {
        if (c == '\r') continue;
        if (n + 2 >= cap) buf = realloc(buf, cap *= 2);
        buf[n++] = c;
    }
    if (n == 0 || buf[n - 1] != '\n') buf[n++] = '\n';
    buf[n] = 0;
    return buf;
}
%}

%%
 /* Délimiteurs : on les recopie simplement */
\n                      { ECHO; }
[ \t]                   { ECHO; }

 /* Deux cas : "a" suivi de n'importe quoi, ou n'importe quoi suivi de "a".
    ^ et $ obligent à vérifier le mot entier. */
^(a[ab]*|[ab]*a)$       { printf("%s  -> ACCEPTE", yytext); }

 /* Règle attrape-tout : signale tout caractère d'un mot non reconnu */
.                       { printf("<?%c>", yytext[0]); }
%%

/* Lit le fichier donné en argument (ou l'entrée standard) puis lance l'analyse */
int main(int argc, char **argv)
{
    FILE *f = (argc > 1) ? fopen(argv[1], "r") : stdin;
    char *buf;
    YY_BUFFER_STATE st;
    if (!f) { perror(argv[1]); return 1; }
    buf = lire(f);
    st = yy_scan_string(buf);      /* l'analyseur lit la chaîne en mémoire */
    yylex();
    yy_delete_buffer(st);
    free(buf);
    return 0;
}
