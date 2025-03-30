#include <iostream>

using namespace std;

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cerr << "Specify the size of the array!" << endl;
        return 1;
    }

    int n = stoi(argv[1]);
    cout << n << endl;

    for (int i = n - 1; i >= 0; i--)
        cout << i << " ";
    
    cout << endl;
}
