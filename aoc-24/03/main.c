#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int main() {
  FILE *f = fopen("input.txt", "r");
  /*FILE *f = fopen("sample.txt", "r");*/
  if (f == NULL) {
    printf("file pointer is null\n");
    return 1;
  }

  char c;
  int i = 0;
  char num1[5];
  char num2[5];
  int result = 0;
  int enabled = 1;
  while ((c = getc(f)) != EOF) {

    if (c == 'd' && getc(f) == 'o') {
      char c1 = getc(f);
      if (c1 == '(' && getc(f) == ')') {
        enabled = 1;
        /*printf("enabled\n");*/
      } else if (c1 == 'n' && getc(f) == '\'' && getc(f) == 't') {
        enabled = 0;
        /*printf("disabled\n");*/
      }
    }

    if (enabled) {
      if (c == 'm' && getc(f) == 'u' && getc(f) == 'l' && getc(f) == '(') {
        if (isdigit(c = getc(f))) {
          int i = 0;
          *num1 = c;
          do {
            num1[i++] = c;
          } while (isdigit(c = getc(f)));
          num1[i] = '\0';
        }
        if (c == ',' && isdigit(c = getc(f))) {
          int j = 0;
          *num2 = c;
          do {
            num2[j++] = c;
          } while (isdigit(c = getc(f)));
          num2[j] = '\0';
        }
        if (c == ')') {
          /*printf("num1: %d, num2: %d, enabled=%d\n", atoi(num1), atoi(num2),*/
          /*       enabled);*/
          result += atoi(num1) * atoi(num2);
        }
      }
    }
  }

  printf("final result: %d\n", result);

  return 0;
}
