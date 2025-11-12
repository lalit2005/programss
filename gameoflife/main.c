#include <raylib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int SCREEN_WIDTH = 1125;
int SCREEN_HEIGHT = 900;
int BLOCKS = 45;

int main() {
  InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "conway's game of life");
  int block_height = SCREEN_HEIGHT / BLOCKS;
  int block_width = SCREEN_WIDTH / BLOCKS;

  char *previous_state = malloc(sizeof(char) * BLOCKS * BLOCKS);
  memset(previous_state, 0, BLOCKS * BLOCKS);
  char *current_state = malloc(sizeof(char) * BLOCKS * BLOCKS);
  memset(current_state, 0, BLOCKS * BLOCKS);

  // int initial_coordinates[][2] = {{1, 2},
  //                                 {BLOCKS / 2, BLOCKS / 2},
  //                                 {BLOCKS / 2 - 1, BLOCKS / 2},
  //                                 {BLOCKS / 2 + 1, BLOCKS / 2}};

  int initial_coordinates[][2] = {
      {2, 2}, {3, 3}, {4, 3}, {4, 2}, {4, 1},
  };

  printf("\n\n\nSIZEEE: %zu\n\n\n",
         sizeof(initial_coordinates) / sizeof(initial_coordinates[0]));

  for (int i = 0;
       i < sizeof(initial_coordinates) / sizeof(initial_coordinates[0]); i++) {
    previous_state[initial_coordinates[i][0] +
                   initial_coordinates[i][1] * BLOCKS] = 1;
    current_state[initial_coordinates[i][0] +
                  initial_coordinates[i][1] * BLOCKS] = 1;
  }

  int x_dirs[] = {-1, -1, 0, 1, 1, 1, 0, -1};
  int y_dirs[] = {0, -1, -1, -1, 0, 1, 1, 1};
  // int x_dirs[] = {-1, 0, 1, 0};
  // int y_dirs[] = {0, 1, 0, 1};

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(WHITE);
    SetTargetFPS(5);

    for (int i = 0; i < BLOCKS; i++) {
      for (int j = 0; j < BLOCKS; j++) {
        int x = i * block_width;
        int y = j * block_height;
        DrawRectangle(x, y, block_width, block_height,
                      current_state[j * BLOCKS + i] == 0 ? GRAY : BLACK);
      }
    }

    for (int i = 0; i < BLOCKS; i++) {
      DrawLine(0, i * block_height, SCREEN_WIDTH, i * block_height, BLACK);
      DrawLine(i * block_width, 0, i * block_width, SCREEN_HEIGHT, BLACK);
    }

    int new = 0;
    for (int i = 0; i < BLOCKS * BLOCKS; i++) {
      int num_of_neighbours = 0;
      for (int d = 0; d < sizeof(x_dirs) / sizeof(x_dirs[0]); d++) {
        new = i + x_dirs[d] * BLOCKS + y_dirs[d];
        if (new >= 0 && new < BLOCKS * BLOCKS) {
          if (previous_state[new] == 1) {
            num_of_neighbours++;
          }
        }
      }

      // Any live cell with fewer than two live neighbours dies, as if by
      // underpopulation.
      //
      // Any live cell with two or three live neighbours lives on to the next
      // generation.
      //
      // Any live cell with more than three live neighbours dies, as if by
      // overpopulation.
      //
      // Any dead cell with exactly three live neighbours becomes a live cell,
      // as if by reproduction.
      // current_state[i] = previous_state[i];

      if (previous_state[i] == 1) {
        switch (num_of_neighbours) {
        case 0:
        case 1:
          current_state[i] = 0;
          break;
        case 2:
        case 3:
          current_state[i] = 1;
          break;
        default:
          current_state[i] = 0;
          break;
        }
      } else { // dead cell
        switch (num_of_neighbours) {
        case 0:
        case 1:
        case 2:
          current_state[i] = 0;
          break;
        case 3:
          current_state[i] = 1;
          break;
        default:
          current_state[i] = 0;
          break;
        }
      }
    }

    char *temp = previous_state;
    previous_state = current_state;
    current_state = temp;

    DrawText("conway's game of life", 10, 10, 18, WHITE);
    DrawText("written by lalit", SCREEN_WIDTH - 150, SCREEN_HEIGHT - 25, 18,
             WHITE);
    EndDrawing();
  }

  CloseWindow();
  free(previous_state);
  free(current_state);
  return 0;
}
