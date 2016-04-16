#include <cmath>
#include <iostream>
#include <fstream>

constexpr double pi = 3.14159265359;

int roundc(double d) {
    return (unsigned char)std::round(d);
}

int main(int argc, char** argv) {
    if(argc != 2) {
        std::fprintf(stderr, "usage: trigtablegen [outfile]");
    }
    std::ofstream out(argv[1]);
    int const table_size = 256;
    out << ".include \"src/globals.inc\"\n";
    out << ".segment \"RODATA\"\n";
    out << "sin_table:";
    for(int i = 0; i != table_size; ++i) {
        double const d = i;
        if(i % 8 == 0)
            out << "\n.byt ";
        else
            out << ',';
        out << roundc(std::sin(d * pi / ((double)table_size/2.0))*127.0);
    }
}
