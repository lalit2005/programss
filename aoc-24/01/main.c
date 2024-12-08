#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_ARRAY_LENGTH 1000
#define MAX_LINE_LENGTH 15

int comp(const void *a, const void *b) { return *(int *)b - *(int *)a; }

int main() {
  FILE *input_file_ptr;
  input_file_ptr = fopen("input.txt", "r");
  if (input_file_ptr == NULL) {
    printf("file pointer null");
    return 1;
  }

  int arr1[MAX_ARRAY_LENGTH];
  int arr2[MAX_ARRAY_LENGTH];
  int count = 0;
  char line[MAX_LINE_LENGTH];

  while (fgets(line, MAX_LINE_LENGTH, input_file_ptr) != NULL) {
    if (sscanf(line, "%d   %d", &arr1[count], &arr2[count]) != 2) {
      fprintf(stderr, "Error parsing line %s", line);
    }
    count++;
  }

  qsort(arr1, count, sizeof(int), comp);
  qsort(arr2, count, sizeof(int), comp);

  int sum = 0;
  for (int i = 0; i < count; i++) {
    sum += abs(arr1[i] - arr2[i]);
  }

  printf("%d", sum);

  fclose(input_file_ptr);
}
