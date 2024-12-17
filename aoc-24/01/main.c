#include <stdio.h>
#include <stdlib.h>

#define MAX_ARRAY_LENGTH 1000
#define MAX_LINE_LENGTH 15

int comp(const void *a, const void *b) { return *(int *)a - *(int *)b; }

int main() {
  FILE *input_file_ptr;
  input_file_ptr = fopen("input.txt", "r");
  if (input_file_ptr == NULL) {
    printf("file pointer is null\n");
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

  printf("sum of distances: %d\n", sum);

  int similarity_score = 0;
  for (int i = 0; i < count; i++) {
    int cur_num = arr1[i];
    int j = 0;
    int count_in_arr2 = 0;
    while (cur_num >= arr2[j]) {
      if (cur_num == arr2[j]) {
        count_in_arr2++;
      }
      j++;
    }
    similarity_score += cur_num * count_in_arr2;
  }

  printf("simlarity score: %d\n", similarity_score);

  fclose(input_file_ptr);
}
