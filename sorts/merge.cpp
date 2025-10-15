#include <iostream>
#include <vector>

using namespace std;

#define printarr(arr)                                                          \
  cout << "[ ";                                                                \
  for (int i = 0; i < arr.size(); i++) {                                       \
    cout << arr.at(i) << " ";                                                  \
  }                                                                            \
  cout << "]" << endl

void merge(vector<int> &arr, int l, int mid, int r) {
  vector<int> temp;
  int left = l;
  int right = mid + 1;
  while (left <= mid && right <= r) {
    if (arr.at(left) < arr.at(right)) {
      temp.push_back(arr.at(left));
      left++;
    } else if (arr.at(right) <= arr.at(left)) {
      temp.push_back(arr.at(right));
      right++;
    }
  }
  while (left <= mid) {
    temp.push_back(arr.at(left));
    left++;
  }
  while (right <= r) {
    temp.push_back(arr.at(right));
    right++;
  }

  for (int i = 0; i < temp.size(); i++) {
    arr[l + i] = temp[i];
  }
}

void merge_sort(vector<int> &arr, int l, int r) {
  if (l >= r)
    return;
  int mid = (l + r) / 2;
  merge_sort(arr, l, mid);
  merge_sort(arr, mid + 1, r);
  merge(arr, l, mid, r);
}

int main() {
  // vector<int> arr = {3, 1, 6, 8};
  vector<int> arr = {3, 1, 6, 8, 2, 7, 0, 7};

  printarr(arr);

  merge_sort(arr, 0, arr.size() - 1);

  printarr(arr);

  return 0;
}
