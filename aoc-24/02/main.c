#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

int is_report_safe(int *report, int len) {
  int is_safe = 1;
  int inc = report[1] - report[0] > 0 ? 1 : 0;
  for (int i = 0; i < len; i++) {
    for (int j = 0; j < len - 1; j++) {
      int diff = report[j + 1] - report[j];
      if (is_safe) {
        if (diff == 0) {
          is_safe = 0;
        } else if (inc && !(diff > 0 && diff < 4)) {
          is_safe = 0;
        } else if (!inc && !(diff < 0 && diff > -4)) {
          is_safe = 0;
        }
      }
    }
  }
  return is_safe;
}

int main() {
  /*FILE *file_pointer = fopen("sample.txt", "r");*/
  FILE *file_pointer = fopen("input.txt", "r");
  if (file_pointer == NULL) {
    printf("file pointer is null\n");
    return 1;
  }

  char *line = NULL;
  size_t len = 0;
  ssize_t read;

  int safe_reports_count = 0;
  int report[15];

  while ((read = getline(&line, &len, file_pointer)) != -1) {
    char *token = strtok(line, " ");
    int i = 0;
    while (token != NULL) {
      report[i++] = atoi(token);
      token = strtok(NULL, " ");
    }
    if (is_report_safe(report, i)) {
      safe_reports_count += 1;
    }
  }

  printf("safe reports: %d\n", safe_reports_count);

  fclose(file_pointer);
  if (line) {
    free(line);
  }
  return 0;
}
