#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void process_line(char *line, int records_count,
                  int records[records_count][100]) {
  int i = 0;
  char *num_string = strtok(line, ',');
  while (num_string != NULL) {
    printf("%s", num_string);
    strtok(line, ',');
  }
}

int main() {

  FILE *f = fopen("sample.txt", "r");
  /*FILE *f = fopen("input.txt", "r");*/
  if (f == NULL) {
    printf("file pointer is null");
    return 1;
  }

  int num1[2000];
  int num2[2000];
  char line[100];
  int rules_count = 0;

  while (fgets(line, sizeof(line), f)) {
    if (strcmp(line, "\n") == 0) {
      break;
    }
    if (sscanf(line, "%d|%d", &num1[rules_count], &num2[rules_count]) == 2) {
      rules_count++;
    } else {
      printf("invalid format in line: %s", line);
    }
  }

  int records[200][100];
  int rec_count;
  int num_count;

  // hell0
  // 5 bytes
  // 5 characters
  while (fgets(line, sizeof(line), f)) {
    rec_count++;
    printf("%s", line);
    process_line(line, rec_count, records);
  }

  printf("%d", rec_count);

  for (int j = 0; j < rules_count; j++) {
    printf("(%d | %d)\n ", num1[j], num2[j]);
  }

  for (int i = 0; i < rec_count; i++) {
  }

  fclose(f);

  return 0;
}
