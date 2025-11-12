#include <raylib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BLOCKS 50
#define MARK_ON_SHIFT                                                          \
  if (IsKeyDown(KEY_LEFT_SHIFT) && !is_sim_running) {                          \
    current_state[cursor] = 1;                                                 \
    previous_state[cursor] = 1;                                                \
  }                                                                            \
  if (IsKeyDown(KEY_RIGHT_SHIFT) && !is_sim_running) {                         \
    current_state[cursor] = 0;                                                 \
    previous_state[cursor] = 0;                                                \
  }
#define INITIAL_POS ((BLOCKS * BLOCKS / 2) - 6) // used while initializing

const int SCREEN_WIDTH = 1200;
const int SCREEN_HEIGHT = 900;
int cursor = 0;
int is_sim_running = 0;

void handle_keybindings(char *previous_state, char *current_state) {
  if (IsKeyPressed(KEY_H) && cursor % BLOCKS > 0) {
    cursor -= 1;
    if (IsKeyDown(KEY_LEFT_SHIFT)) {
      current_state[cursor] = 1;
      MARK_ON_SHIFT;
    }
  }
  if (IsKeyPressedRepeat(KEY_H) && cursor % BLOCKS > 0) {
    cursor -= 1;
    MARK_ON_SHIFT;
  }

  if (IsKeyPressed(KEY_J) && cursor < BLOCKS * (BLOCKS - 1)) {
    cursor += BLOCKS;
    MARK_ON_SHIFT;
  }

  if (IsKeyPressedRepeat(KEY_J) && cursor < BLOCKS * (BLOCKS - 1)) {
    cursor += BLOCKS;
    MARK_ON_SHIFT;
  }

  if (IsKeyPressed(KEY_K) && cursor > BLOCKS) {
    cursor -= BLOCKS;
    MARK_ON_SHIFT;
  }

  if (IsKeyPressedRepeat(KEY_K) && cursor > BLOCKS) {
    cursor -= BLOCKS;
    MARK_ON_SHIFT;
  }

  if (IsKeyPressed(KEY_L) && cursor % BLOCKS < BLOCKS - 1) {
    cursor += 1;
    MARK_ON_SHIFT;
  }

  if (IsKeyPressedRepeat(KEY_L) && cursor % BLOCKS < BLOCKS - 1) {
    cursor += 1;
    MARK_ON_SHIFT;
  }

  if (IsKeyPressedRepeat(KEY_C)) {
    memset(previous_state, 0, BLOCKS * BLOCKS);
    memset(current_state, 0, BLOCKS * BLOCKS);
  }

  if (IsKeyPressed(KEY_SPACE) && !is_sim_running) {
    current_state[cursor] = !current_state[cursor];
    previous_state[cursor] = !previous_state[cursor];
  }

  if (IsKeyPressed(KEY_ENTER)) {
    is_sim_running = !is_sim_running;
  }
}

int main() {
  InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "conway's game of life");
  int block_height = SCREEN_HEIGHT / BLOCKS;
  int block_width = SCREEN_WIDTH / BLOCKS;

  char *previous_state = malloc(sizeof(char) * BLOCKS * BLOCKS);
  memset(previous_state, 0, BLOCKS * BLOCKS);
  char *current_state = malloc(sizeof(char) * BLOCKS * BLOCKS);
  memset(current_state, 0, BLOCKS * BLOCKS);

  // {2, 2}, {3, 3}, {4, 3}, {4, 2}, {4, 1},
  // 012345678901
  // 1  11 1111 1
  // 111111 11  1
  // 012345678901
  int initial_coordinates[][2] = {
      {INITIAL_POS, INITIAL_POS},         {INITIAL_POS + 3, INITIAL_POS},
      {INITIAL_POS + 4, INITIAL_POS},     {INITIAL_POS + 6, INITIAL_POS},
      {INITIAL_POS + 7, INITIAL_POS},     {INITIAL_POS + 8, INITIAL_POS},
      {INITIAL_POS + 9, INITIAL_POS},     {INITIAL_POS + 11, INITIAL_POS},
      {INITIAL_POS, INITIAL_POS + 1},     {INITIAL_POS + 1, INITIAL_POS + 1},
      {INITIAL_POS + 2, INITIAL_POS + 1}, {INITIAL_POS + 3, INITIAL_POS + 1},
      {INITIAL_POS + 4, INITIAL_POS + 1}, {INITIAL_POS + 5, INITIAL_POS + 1},
      {INITIAL_POS + 7, INITIAL_POS + 1}, {INITIAL_POS + 8, INITIAL_POS + 1},
      {INITIAL_POS + 1, INITIAL_POS + 1},
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
    SetTargetFPS(50);

    handle_keybindings(previous_state, current_state);

    for (int i = 0; i < BLOCKS; i++) {
      for (int j = 0; j < BLOCKS; j++) {
        int x = i * block_width;
        int y = j * block_height;
        DrawRectangle(x, y, block_width, block_height,
                      current_state[j * BLOCKS + i] == 0 ? GRAY : BLACK);
        if (cursor == j * BLOCKS + i) {
          DrawCircle(x + block_width / 2, y + block_height / 2,
                     ((float)block_width + (float)block_height) / 5, WHITE);
        }
      }
    }

    // for (int i = 0; i < BLOCKS; i++) {
    //   DrawLine(0, i * block_height, SCREEN_WIDTH, i * block_height, BLACK);
    //   DrawLine(i * block_width, 0, i * block_width, SCREEN_HEIGHT, BLACK);
    // }

    if (is_sim_running) {
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
    }

    DrawText(is_sim_running ? "conway's game of life"
                            : "conway's game of life [PAUSED]",
             10, 10, 22, WHITE);
    DrawText("written by lalit", SCREEN_WIDTH - 150, 10, 18, WHITE);
    DrawText(
        "hjkl - cursor | space - toggle mark in cell | enter - pause/resume | "
        "l-shift+move - mark | r-shift+move - unmark | longpress c - clear",
        10, SCREEN_HEIGHT - 25, 18, WHITE);
    EndDrawing();
  }

  CloseWindow();
  free(previous_state);
  free(current_state);
  return 0;
}
