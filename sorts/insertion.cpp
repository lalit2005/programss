#include <iostream>
#include <vector>
using namespace std;

#define printarr(arr)                                                          \
  cout << "[ ";                                                                \
  for (int i = 0; i < arr.size(); i++) {                                       \
    cout << arr.at(i) << " ";                                                  \
  }                                                                            \
  cout << "]" << endl

int main() {
  vector<float> arr = {3, 1, 6, 8, 2, 7.5, 0, 7};

  printarr(arr);
  for (int i = 0; i < arr.size(); i++) {
    int j = i;
    while (j > 0 && arr.at(j) < arr.at(j - 1)) { // ascending order
      // while (j > 0 && arr.at(j) > arr.at(j - 1)) { // descending order
      auto temp = arr[j];
      arr[j] = arr[j - 1];
      arr[j - 1] = temp;
      j--;
    }
  }

  printarr(arr);

  return 0;
}
