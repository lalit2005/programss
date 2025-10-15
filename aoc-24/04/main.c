#include <stdio.h>
#include <stdlib.h>

// assuming rows = columns
/*#define MAX_SIZE 10 // for sample.txt*/
#define MAX_SIZE 140 // for input.txt

int main() {

  /*FILE *f = fopen("sample.txt", "r");*/
  FILE *f = fopen("input.txt", "r");

  if (f == NULL) {
    printf("file pointer is null");
    return 1;
  }

  char lm[MAX_SIZE + 2][MAX_SIZE + 2]; // letter matrix
  char c;
  int cur_line = 1, cur_col = 1;

  while ((c = getc(f)) != EOF) {
    if (c == '\n') {
      cur_line += 1;
      cur_col = 1;
    } else {
      lm[cur_line][cur_col++] = c;
    }
  }

  for (int i = 0; i < MAX_SIZE + 2; i++) {
    lm[0][i] = '0';            // set the first row to 0
    lm[MAX_SIZE + 1][i] = '0'; // set the last row to 0
    lm[i][0] = '0';            // first char of every line is 0
    lm[i][MAX_SIZE + 1] = '0'; // last char of every line is 0
  }

  int count = 0;

  for (int line = 0; line < MAX_SIZE + 2; line++) {
    for (int col = 0; col < MAX_SIZE + 2; col++) {
      // PART TWO
      if (lm[line][col] == 'A') {
        // M.S
        // .A.
        // M.S
        if (lm[line - 1][col - 1] == 'M' && lm[line - 1][col + 1] == 'S' &&
            lm[line + 1][col - 1] == 'M' && lm[line + 1][col + 1] == 'S') {
          count++;
        }
        if (lm[line - 1][col - 1] == 'M' && lm[line - 1][col + 1] == 'M' &&
            lm[line + 1][col - 1] == 'S' && lm[line + 1][col + 1] == 'S') {
          count++;
        }
        if (lm[line - 1][col - 1] == 'S' && lm[line - 1][col + 1] == 'M' &&
            lm[line + 1][col - 1] == 'S' && lm[line + 1][col + 1] == 'M') {
          count++;
        }
        if (lm[line - 1][col - 1] == 'S' && lm[line - 1][col + 1] == 'S' &&
            lm[line + 1][col - 1] == 'M' && lm[line + 1][col + 1] == 'M') {
          count++;
        }
      }

      // PART ONE
      /*if (lm[line][col] == 'X') {*/
      /*  // X...*/
      /*  if (lm[line][col + 1] == 'M' && lm[line][col + 2] == 'A' &&*/
      /*      lm[line][col + 3] == 'S') {*/
      /*    count++;*/
      /*  }*/
      /*  // ...X*/
      /*  if (lm[line][col - 1] == 'M' && lm[line][col - 2] == 'A' &&*/
      /*      lm[line][col - 3] == 'S') {*/
      /*    count++;*/
      /*  }*/
      /*  // .*/
      /*  // X*/
      /*  if (lm[line - 1][col] == 'M' && lm[line - 2][col] == 'A' &&*/
      /*      lm[line - 3][col] == 'S') {*/
      /*    count++;*/
      /*  }*/
      /*  // X*/
      /*  // .*/
      /*  if (lm[line + 1][col] == 'M' && lm[line + 2][col] == 'A' &&*/
      /*      lm[line + 3][col] == 'S') {*/
      /*    count++;*/
      /*  }*/
      /*  //  .*/
      /*  // X*/
      /*  if (lm[line - 1][col + 1] == 'M' && lm[line - 2][col + 2] == 'A' &&*/
      /*      lm[line - 3][col + 3] == 'S') {*/
      /*    count++;*/
      /*  }*/
      /*  // .*/
      /*  //  X*/
      /*  if (lm[line - 1][col - 1] == 'M' && lm[line - 2][col - 2] == 'A' &&*/
      /*      lm[line - 3][col - 3] == 'S') {*/
      /*    count++;*/
      /*  }*/
      /*  // X*/
      /*  //  .*/
      /*  if (lm[line + 1][col + 1] == 'M' && lm[line + 2][col + 2] == 'A' &&*/
      /*      lm[line + 3][col + 3] == 'S') {*/
      /*    count++;*/
      /*  }*/
      /*  //  X*/
      /*  // .*/
      /*  if (lm[line + 1][col - 1] == 'M' && lm[line + 2][col - 2] == 'A' &&*/
      /*      lm[line + 3][col - 3] == 'S') {*/
      /*    count++;*/
      /*  }*/
      /*}*/
    }
  }

  printf("final count: %d\n", count);

  return 0;
}
