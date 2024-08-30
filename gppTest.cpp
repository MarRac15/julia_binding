#include <iostream>
using namespace std;

extern "C" {int NWD(int a, int b)
{
    int temp;
    while(b!=0){
        temp = b;
        b = a%b;
        a = temp;
    }
    return a;
}
}

int main() {
    cout << "NWD equals: "<<  NWD(12, 56) << endl;
    return 0;
}