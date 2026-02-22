#include <assert.h>
#include <dirent.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#define UNDERLINE_START "\x1b[4m"
#define UNDERLINE_STOP "\x1b[24m"
#define BOLD_START "\x1b[1m"
#define BOLD_STOP "\x1b[22m"
#define GREEN_FG "\x1b[38;5;118m"
#define RESET_STYLE "\x1b[0m"
#define DIM_START "\x1b[2m"
#define DIM_STOP "\x1b[22m"
#define CURSOR_UP "\x1b[1A"
#define ERASE_LINE "\x1b[2K"

int depth = 1;
int case_sensitive = 0;
int show_ignored_files = 0;
int is_gitignore_present = 0;
int gitignore_files_idx = 0;
int should_print_config = 0;
ino_t gitignore_files[256];
int total_results_count = 0;

// typedef struct {
//   int line_no;
//   char prev_line[256];
//   char line[256];
//   char next_line[256];
// } Match;

void print_config(const char *query) {
  printf("Query  : \"%s\"\n", query);
  printf("Case   : %s\n", case_sensitive == 1 ? "Sensitive" : "Insensitive");
  printf("Depth  : %d\n", depth);

  if (show_ignored_files) { // files can be ignored for many reaons
    if (gitignore_files_idx > 0) {
      printf("Ignored:\n");
      for (int i = 0; i < gitignore_files_idx; i++) {
        printf("  GI - %d\n", (int)gitignore_files[i]);
      }
    }
  }
}

int gitignore_contains(ino_t file_ino) {
  for (int i = 0; i < gitignore_files_idx; i++) {
    if (gitignore_files[i] == file_ino) {
      return 1;
    }
  }
  return 0;
}

void gitignore_init() {
  FILE *gitignore_fp;
  if ((gitignore_fp = fopen(".gitignore", "r")) != NULL) {
    is_gitignore_present = 1;
    char buf[256];
    struct stat file_stat;
    while (fgets(buf, sizeof(buf), gitignore_fp) != NULL) {
      *strchr(buf, '\n') = '\0';
      if (stat(buf, &file_stat) == 0) {
        gitignore_files[gitignore_files_idx++] = file_stat.st_ino;
      }
    }
    fclose(gitignore_fp);
  }
}

void search_file(const char *file_path, const char *query) {
  int query_len = strlen(query);
  FILE *fp = fopen(file_path, "r");
  char buf[256];
  int line = 0;
  char *result = NULL;
  int results_count = 0;
  int dim_flag = 0;
  while (fgets(buf, sizeof(buf), fp) != NULL) {
    line++;
    if (case_sensitive) {
      if ((result = strstr(buf, query)) != NULL) {
        if (dim_flag)
          printf(DIM_START);
        do {
          results_count++;
          results_count == 1 && printf(UNDERLINE_START BOLD_START
                                       "%s" BOLD_STOP UNDERLINE_STOP "\n",
                                       file_path + 2); // ignore the "./"
          printf("  %04d | %.*s", line, (int)(result - buf), buf);
          printf(RESET_STYLE GREEN_FG BOLD_START "%.*s" BOLD_STOP RESET_STYLE,
                 query_len, result);

          if (dim_flag)
            printf(DIM_START);

          printf("%s", result + query_len);
        } while ((result = strstr(result + query_len, query)) != NULL);
        printf(DIM_STOP);
        dim_flag = !dim_flag;
      }
    } else {
      if ((result = strcasestr(buf, query)) != NULL) {
        if (dim_flag)
          printf(DIM_START);
        do {
          results_count++;
          results_count == 1 && printf(UNDERLINE_START BOLD_START
                                       "%s" BOLD_STOP UNDERLINE_STOP "\n",
                                       file_path + 2); // ignore the "./"
          printf("  %04d | %.*s", line, (int)(result - buf), buf);
          printf(RESET_STYLE GREEN_FG BOLD_START "%.*s" BOLD_STOP RESET_STYLE,
                 query_len, result);

          if (dim_flag)
            printf(DIM_START);

          printf("%s", result + query_len);
        } while ((result = strcasestr(result + query_len, query)) != NULL);
        printf(DIM_STOP);
        dim_flag = !dim_flag;
      }
    }
  }

  if (results_count > 0) {
    printf("%d match%s found in \"%s\"\n", results_count,
           results_count > 1 ? "es" : "", file_path);
    printf("\n");
  }
  total_results_count += results_count;
  fclose(fp);
}

void search_directory(const char *path, const char *query, int rem_depth) {
  if (rem_depth < 1)
    return;

  DIR *d = opendir(path);
  struct dirent *de;

  while ((de = readdir(d)) != NULL) {
    if (de->d_name[0] == '.')
      // if (strcmp(de->d_name, ".") == 0 || strcmp(de->d_name, "..") == 0)
      continue;

    if (!gitignore_contains(de->d_ino)) {
      char new_path[2048];
      new_path[0] = '\0';
      strcat(new_path, path);
      strcat(new_path, "/");
      strcat(new_path, de->d_name);
      if (de->d_type == DT_REG) {
        search_file(new_path, query);
      } else if (de->d_type == DT_DIR) {
        search_directory(new_path, query, rem_depth - 1);
      }
    }
  }
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("USAGE:\n");
    printf("$ grep.out hello [flags]\n\n");
    printf(
        "-i    Performs case sensitive search. Case insensitive by default\n");
    printf("-d=n  Depth (not implemented yet)\n");
    printf("-g    List ignored files along with search results\n");
    printf("-c    Print config for the search\n");
    return 0;
  }

  char *query = argv[1];

  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "-i") == 0) {
      case_sensitive = 1;
    } else if (strcmp(argv[i], "-g") == 0) {
      show_ignored_files = 1;
    } else if (strcmp(argv[i], "-c") == 0) {
      should_print_config = 1;
    } else if (strncmp(argv[i], "-d=", 3) == 0) {
      char *endptr;
      long n = strtol(argv[i] + 3, &endptr, 10);
      assert(*endptr == '\0');
      depth = (int)n; // TODO : make this num conversion better
      if (depth < 0 || n > INT_MAX) {
        printf("Invalid depth\n");
        exit(1);
      }
    }
  }

  gitignore_init();

  printf(BOLD_START "Searching for \"%s\"" BOLD_START "\n\n", query);

  search_directory(".", query, depth);

  if (should_print_config) {
    print_config(query);
    printf("===================\n");
  }

  printf("\n");
  printf("Found %d match%s\n", total_results_count,
         total_results_count > 1 ? "es" : "");

  return 0;
}
