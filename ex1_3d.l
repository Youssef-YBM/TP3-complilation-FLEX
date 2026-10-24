%option noyywrap
L   [a-zA-Z]

%{
#include <stdio.h>
#include <stdlib.h>

/* lit tout le fichier : supprime les \r (fichiers Windows) et garantit un \n final */
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
\n                      { ECHO; }
[ \t]                   { ECHO; }
^(b+)?(a+bb+)*(a+b?)?$    { printf("  -> ACCEPTE"); }
.                       { printf("<?%c>", yytext[0]); }
%%
int main(int argc, char **argv)
{
    FILE *f = (argc > 1) ? fopen(argv[1], "r") : stdin;
    char *buf;
    YY_BUFFER_STATE st;
    if (!f) { perror(argv[1]); return 1; }
    buf = lire(f);
    st = yy_scan_string(buf);
    yylex();
    yy_delete_buffer(st);
    free(buf);
    return 0;
}
