/* TP3 Compilation : tous les exercices dans un seul analyseur, avec menu.
 *
 * Principe : chaque exercice correspond à une condition de départ (%x).
 * Une règle préfixée par <E13B> n'est active que lorsque l'analyseur est
 * dans l'état E13B. Le menu (dans main) choisit l'état avec BEGIN(...).
 */

/* Pas de yywrap : l'analyse s'arrête à la fin du texte */
%option noyywrap

/* Conditions de départ exclusives (une par exercice) :
 *   E11A  = ex 1.1 a)     E11B1 = ex 1.1 b1)    E11B2 = ex 1.1 b2)
 *   E12   = ex 1.2 (texte normal)   E12C = ex 1.2 (à l'intérieur d'un commentaire)
 *   E13A..E13D = ex 1.3 a) à d)
 */
%x E11A E11B1 E11B2 E12 E12C E13A E13B E13C E13D

/* Macros (abréviations d'expressions régulières) */
L       [a-zA-Z]
EXP     [eE][-+]?[0-9]+
KW      for|while|if|else|do|int|float|char|return|void|switch|case|break

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Variables C utilisées dans les actions de l'exercice 1.2 */
int nb_comm = 0;     /* nombre de commentaires supprimés */
int nb_lignes = 0;   /* nombre de sauts de ligne à l'intérieur des commentaires */
%}

%%

 /* ---------- Exercice 1.1 a) : symboles ---------- */
 /* lettre suivie de lettres/chiffres, affichée entre < > */
<E11A>{L}[a-zA-Z0-9]*      { printf("<%s> ", yytext); }

 /* ---------- Exercice 1.1 b1) : mots-clés, symboles, opérateurs ---------- */
 /* Les mots-clés d'abord : à longueur égale, la première règle gagne */
<E11B1>{KW}                { printf("<MOT-CLE:%s> ", yytext); }
<E11B1>{L}[a-zA-Z0-9]*     { printf("<SYMBOLE:%s> ", yytext); }
 /* opérateurs à deux caractères (plus longs, donc prioritaires) */
<E11B1>"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="  { printf("<OPERATEUR:%s> ", yytext); }
 /* opérateurs à un caractère */
<E11B1>[-+*/%=<>!&|^~]     { printf("<OPERATEUR:%s> ", yytext); }
 /* caractères réservés : parenthèses, accolades, crochets, ponctuation */
<E11B1>[(){}\[\];,.:]      { printf("<OPERATEUR:%s> ", yytext); }

 /* ---------- Exercice 1.1 b2) : + valeurs numériques ---------- */
<E11B2>{KW}                { printf("<MOT-CLE:%s> ", yytext); }
<E11B2>{L}[a-zA-Z0-9]*     { printf("<SYMBOLE:%s> ", yytext); }
 /* entier : suite de chiffres */
<E11B2>[0-9]+              { printf("<ENTIER:%s> ", yytext); }
 /* flottant : 12.3   12.   .5   1e5   2.5e-3 (plus long que l'entier, donc prioritaire) */
<E11B2>[0-9]+"."[0-9]*({EXP})?|"."[0-9]+({EXP})?|[0-9]+{EXP}  { printf("<FLOTTANT:%s> ", yytext); }
<E11B2>"++"|"--"|"=="|"!="|"<="|">="|"&&"|"||"|"+="|"-="  { printf("<OPERATEUR:%s> ", yytext); }
<E11B2>[-+*/%=<>!&|^~]     { printf("<OPERATEUR:%s> ", yytext); }
<E11B2>[(){}\[\];,.:]      { printf("<OPERATEUR:%s> ", yytext); }

 /* ---------- Exercice 1.2 : suppression des commentaires ---------- */
 /* chaîne C : recopiée sans y toucher (un faux commentaire dedans reste intact) */
<E12>\"([^"\\\n]|\\.)*\"   { ECHO; }
 /* début de commentaire : on passe dans l'état E12C et on compte */
<E12>"/*"                  { BEGIN(E12C); nb_comm++; }
 /* fin de commentaire : retour à l'état normal */
<E12C>"*/"                 { BEGIN(E12); }
 /* dans un commentaire : on compte les lignes, le reste est ignoré */
<E12C>\n                   { nb_lignes++; }
<E12C>.                    { /* on ignore le caractère */ }
 /* fichier fini avant la fin du commentaire : erreur */
<E12C><<EOF>>              { fprintf(stderr, "Erreur : commentaire non termine\n"); return 0; }

 /* ---------- Exercice 1.3 : un mot par ligne ---------- */
 /* délimiteurs : recopiés tels quels */
<E13A,E13B,E13C,E13D>\n    { ECHO; }
<E13A,E13B,E13C,E13D>[ \t] { ECHO; }

 /* ^ = début de ligne, $ = fin de ligne : on vérifie le mot entier */
 /* a) les 5 voyelles dans l'ordre, avec des lettres quelconques entre elles */
<E13A>^{L}*[aA]{L}*[eE]{L}*[iI]{L}*[oO]{L}*[uU]{L}*$   { printf("%s  -> ACCEPTE", yytext); }
 /* b) commence ou finit par a */
<E13B>^(a[ab]*|[ab]*a)$                                { printf("%s  -> ACCEPTE", yytext); }
 /* c) pas deux lettres identiques de suite : le mot alterne (abab... ou baba...) */
<E13C>^((ab)+a?|(ba)+b?|a|b)$                          { printf("%s  -> ACCEPTE", yytext); }
 /* d) pas de sous-chaîne aba : tout bloc de b entre deux blocs de a contient au moins 2 b */
<E13D>^(b+)?(a+bb+)*(a+b?)?$                           { printf("%s  -> ACCEPTE", yytext); }

 /* règle attrape-tout : signale chaque caractère d'un mot non reconnu */
<E13A,E13B,E13C,E13D>.     { printf("<?%c>", yytext[0]); }

%%

/* Lit tout le fichier en mémoire :
 *  - supprime les \r (fichiers créés sous Windows)
 *  - garantit qu'il y a un \n à la fin (nécessaire pour les règles ancrées par $)
 */
static char *lire(FILE *f)
{
    size_t n = 0, cap = 1024;
    char *buf = malloc(cap);
    int c;
    while ((c = fgetc(f)) != EOF) {
        if (c == '\r') continue;
        if (n + 2 >= cap) buf = realloc(buf, cap *= 2);   /* agrandit le tampon si besoin */
        buf[n++] = c;
    }
    if (n == 0 || buf[n - 1] != '\n') buf[n++] = '\n';
    buf[n] = 0;
    return buf;
}

/* Saisie au clavier : on lit des lignes jusqu'à une ligne contenant seulement un point */
static char *lire_clavier(void)
{
    size_t n = 0, cap = 1024;
    char *buf = malloc(cap), l[512];
    printf("Tapez le texte (une ligne contenant seulement '.' pour terminer) :\n");
    while (fgets(l, sizeof l, stdin)) {
        size_t m;
        l[strcspn(l, "\r\n")] = 0;          /* retire le retour à la ligne */
        if (strcmp(l, ".") == 0)
            break;                          /* fin de la saisie */
        m = strlen(l);
        while (n + m + 2 >= cap) buf = realloc(buf, cap *= 2);
        memcpy(buf + n, l, m);
        n += m;
        buf[n++] = '\n';
    }
    buf[n] = 0;
    return buf;
}

/* Analyse un texte avec l'exercice choisi.
 *   cond : condition de départ (l'exercice à exécuter)
 *   nom  : nom du fichier à lire, ou NULL pour une saisie au clavier
 */
static void analyser(int cond, const char *nom)
{
    char *buf;
    YY_BUFFER_STATE st;

    if (!nom) {
        buf = lire_clavier();
        nom = "clavier";
    } else {
        FILE *f = fopen(nom, "r");
        if (!f) {
            perror(nom);                    /* fichier introuvable */
            return;
        }
        buf = lire(f);
        fclose(f);
    }

    nb_comm = nb_lignes = 0;                /* remise à zéro des compteurs de l'ex 1.2 */
    printf("\n----- resultat (%s) -----\n", nom);
    st = yy_scan_string(buf);               /* l'analyseur lit la chaîne en mémoire */
    BEGIN(cond);                            /* active les règles de l'exercice choisi */
    yylex();
    yy_delete_buffer(st);
    free(buf);
    if (cond == E12)
        printf("\n[%d commentaire(s) supprime(s), %d saut(s) de ligne dans les commentaires]\n",
               nb_comm, nb_lignes);
    printf("\n----- fin -----\n");
}

/* Menu principal */
int main(void)
{
    /* Tableau des exercices : titre affiché, condition de départ, fichier par défaut */
    static const struct {
        const char *titre;
        int cond;
        const char *defaut;
    } ex[] = {
        { "Ex 1.1 a)  symboles (lettre puis lettres/chiffres)", E11A,  "0.dat"  },
        { "Ex 1.1 b1) mots-cles, operateurs, symboles",         E11B1, "0.dat"  },
        { "Ex 1.1 b2) + valeurs numeriques",                    E11B2, "0.dat"  },
        { "Ex 1.2     suppression des commentaires C",          E12,   "prog.c" },
        { "Ex 1.3 a)  les 5 voyelles dans l'ordre",             E13A,  "a.txt"  },
        { "Ex 1.3 b)  {a,b} commence ou finit par a",           E13B,  "b.txt"  },
        { "Ex 1.3 c)  {a,b} sans 2 lettres identiques de suite", E13C, "c.txt"  },
        { "Ex 1.3 d)  {a,b} sans la sous-chaine aba",           E13D,  "d.txt"  },
    };
    char ligne[256];
    int i, choix;

    for (;;) {
        /* Affichage du menu */
        printf("\n===== TP3 - MENU =====\n");
        for (i = 0; i < 8; i++)
            printf("  %d. %s\n", i + 1, ex[i].titre);
        printf("  0. Quitter\n");
        printf("Votre choix : ");
        if (!fgets(ligne, sizeof ligne, stdin))
            break;                          /* fin de l'entrée : on quitte */
        choix = atoi(ligne);
        if (choix == 0)
            break;
        if (choix < 1 || choix > 8) {
            printf("Choix invalide.\n");
            continue;
        }

        /* Choix de la source du texte : fichier par défaut, autre fichier, ou clavier */
        printf("Fichier a analyser (Entree = %s, k = saisie au clavier) : ", ex[choix - 1].defaut);
        if (!fgets(ligne, sizeof ligne, stdin))
            break;
        ligne[strcspn(ligne, "\r\n")] = 0;
        if (strcmp(ligne, "k") == 0)
            analyser(ex[choix - 1].cond, NULL);
        else
            analyser(ex[choix - 1].cond, ligne[0] ? ligne : ex[choix - 1].defaut);
    }
    return 0;
}
