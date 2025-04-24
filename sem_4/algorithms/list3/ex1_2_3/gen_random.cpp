#include <iostream>
#include <random>

using namespace std;

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cerr << "Specify the size of the array!" << endl;
        return 1;
    }

    int n = stoi(argv[1]);
    cout << n << endl;

    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<int> dist(0, 2 * n - 1);

    for (int i = 0; i < n; i++)
        cout << dist(gen) << " ";
    
    cout << endl;
}
