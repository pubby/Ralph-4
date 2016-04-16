#include <cstdio>
#include <cstdlib>
#include <algorithm>
#include <array>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

constexpr int W = 16; // width
constexpr int H = 15; // height

constexpr char ralph_char = '&';

using grid_t = std::array<std::array<char, W>, H>;

struct coord_t {
    int x;
    int y;
};

bool operator==(coord_t lhs, coord_t rhs) {
    return lhs.x == rhs.x && lhs.y == rhs.y;
}

bool operator!=(coord_t lhs, coord_t rhs) {
    return !(lhs == rhs);
}

struct enemy_t {
    int attr;
    coord_t pos;
};

int compress_xy(coord_t c) {
    return c.x | ((c.y * 16) & 0b11110000);
}

// Use this to find ralph and the gem.
coord_t get_1_object(grid_t grid, char obj_ch, std::string error_prefix) {
    coord_t ret = {0};
    for(int y = 0; y != H; ++y)
    for(int x = 0; x != W; ++x) {
        if(grid[y][x] == obj_ch) {
            if(ret != coord_t{0}) {
                throw std::runtime_error(
                    error_prefix + ": duplicate chars: " + obj_ch);
            }
            ret = {x,y};
        }
    }
    return ret;
}

// Modifies grid by replacing enemy chars with '.'
std::vector<enemy_t> extract_enemies(grid_t& grid, std::string error_prefix) {
    constexpr int SPEED1 = 0b00000000;
    constexpr int SPEED2 = 0b00000001;
    constexpr int SPEED3 = 0b00000010;
    constexpr int SPEED4 = 0b00000011;

    // Bouncey movement
    constexpr int RIGHT = 0b00000000;
    constexpr int DOWN  = 0b00000100;
    constexpr int LEFT  = 0b00001000;
    constexpr int UP    = 0b00001100;
    constexpr int REVERSE = 0b00100000;
    constexpr int TURN_RIGHT = 0b00010000;
    constexpr int TURN_LEFT  = 0b00110000;

    // Circular movement
    constexpr int CIRCULAR       = 0b01000000;
    constexpr int ANGLE_270      = 0b00110000;
    constexpr int ANGLE_180      = 0b00100000;
    constexpr int ANGLE_90       = 0b00010000;
    constexpr int HALF_RADIUS    = 0b00000100;
    constexpr int QUARTER_RADIUS = 0b00001000;
    constexpr int EIGHTH_RADIUS  = 0b00001100;

    std::vector<enemy_t> ret;
    for(int y = 0; y != H; ++y)
    for(int x = 0; x != W; ++x) {
        enemy_t e = {0, {x,y}};
        switch(grid[y][x]) {
        case '>': e.attr |= SPEED4;
        case 'R': e.attr |= SPEED2;
        case 'r': e.attr |= REVERSE | RIGHT; break;

        case 'v': e.attr |= SPEED4;
        case 'D': e.attr |= SPEED2;
        case 'd': e.attr |= REVERSE | DOWN; break;

        case '<': e.attr |= SPEED4;
        case 'L': e.attr |= SPEED2;
        case 'l': e.attr |= REVERSE | LEFT; break;

        case '^': e.attr |= SPEED4;
        case 'U': e.attr |= SPEED2;
        case 'u': e.attr |= REVERSE | UP; break;

        case '[': e.attr |= TURN_RIGHT | LEFT; break;
        case '{': e.attr |= TURN_RIGHT | LEFT | SPEED2; break;
        case ']': e.attr |= TURN_RIGHT | RIGHT; break;
        case '}': e.attr |= TURN_RIGHT | RIGHT | SPEED2; break;

        case '(': e.attr |= TURN_LEFT | LEFT | SPEED2; break;
        case ')': e.attr |= TURN_LEFT | RIGHT | SPEED2; break;

        case '+': e.attr = CIRCULAR | EIGHTH_RADIUS | SPEED2; break;
        case '*': e.attr = CIRCULAR | EIGHTH_RADIUS | SPEED3; break;
        case 'o': e.attr = CIRCULAR | QUARTER_RADIUS | SPEED2; break;
        case 'O': e.attr = CIRCULAR | HALF_RADIUS | SPEED2; break;
        case 'q': e.attr = CIRCULAR | ANGLE_180 | QUARTER_RADIUS | SPEED2; break;
        case 'Q': e.attr = CIRCULAR | ANGLE_180 | HALF_RADIUS | SPEED2; break;
        case 'j': e.attr = CIRCULAR | ANGLE_90 | QUARTER_RADIUS | SPEED2; break;
        case 'J': e.attr = CIRCULAR | ANGLE_90 | HALF_RADIUS | SPEED2; break;
        case 'h': e.attr = CIRCULAR | ANGLE_270 | QUARTER_RADIUS | SPEED2; break;
        case 'H': e.attr = CIRCULAR | ANGLE_270 | HALF_RADIUS | SPEED2; break;

        case '@': 
            ret.push_back({ CIRCULAR | SPEED3 | ANGLE_180 | EIGHTH_RADIUS, {x,y}});
            ret.push_back({ CIRCULAR | SPEED3 | QUARTER_RADIUS, {x,y}});
            ret.push_back({ CIRCULAR | SPEED3 | ANGLE_180 | HALF_RADIUS, {x,y}});
            goto alreadyPushed;

        case 'c': 
            ret.push_back({ CIRCULAR | SPEED2 | QUARTER_RADIUS, {x,y}});
            ret.push_back({ CIRCULAR | ANGLE_90 | SPEED2 | QUARTER_RADIUS, {x,y}});
            ret.push_back({ CIRCULAR | ANGLE_180 | SPEED2 | QUARTER_RADIUS, {x,y}});
            goto alreadyPushed;

        case 'k': 
            ret.push_back({ CIRCULAR | ANGLE_270 | SPEED2 | QUARTER_RADIUS, {x,y}});
            ret.push_back({ CIRCULAR | SPEED2 | QUARTER_RADIUS, {x,y}});
            ret.push_back({ CIRCULAR | ANGLE_180 | SPEED2 | QUARTER_RADIUS, {x,y}});
            goto alreadyPushed;

        case '=':
            e.attr |= TURN_RIGHT | RIGHT | SPEED2;
            ret.push_back(e);
            grid[y][x] = ',';
            continue;
        default: continue;
        }
        ret.push_back(e);
    alreadyPushed:
        grid[y][x] = '.';
    }
    return ret;
}

std::vector<unsigned char> get_uncompressed_tiles(grid_t grid,
                                                  std::string error_prefix,
                                                  int i, int size) {
    std::vector<unsigned char> uncompressed_tiles;
    for(int y = 0; y != H; ++y)
    for(int x = 0; x != W; ++x) {
        char const ch = grid[y][x];
        switch(ch) {
        case '`':
            uncompressed_tiles.push_back(3);
            break;
        case ',':
            uncompressed_tiles.push_back(0);
            break;
        case '\'':
        case '.':
            uncompressed_tiles.push_back(1);
            break;
        case '%':
            uncompressed_tiles.push_back(12);
            break;
        case 'X':
            uncompressed_tiles.push_back(13);
            break;
        case '#':
            uncompressed_tiles.push_back(14);
            break;
        case 'E':
            uncompressed_tiles.push_back(15);
            break;
        case '"':
            if(i == (size - 1))
                uncompressed_tiles.push_back(7);
            else
                uncompressed_tiles.push_back(6);
            break;
        case 't':
            uncompressed_tiles.push_back(9);
            break;
        case 'e':
            uncompressed_tiles.push_back(10);
            break;
        case '!':
            uncompressed_tiles.push_back(11);
            break;
        case ralph_char:
            if(i == 0)
                uncompressed_tiles.push_back(1);
            else
                uncompressed_tiles.push_back(2);
            break;
        default:
            throw std::runtime_error(error_prefix 
                                     + ": bad character; " + ch);
        }
    }
    return uncompressed_tiles;
}

std::vector<unsigned char> compress_tiles(std::vector<unsigned char> un) {
    int total_count = 0;
    std::vector<unsigned char> compressed;
    for(int i = 0; i < un.size();) {
        unsigned char ch = un[i];
        if(ch >= 16)
            throw std::runtime_error("bad tile");
        int count = 0;
        for(;un[i] == ch && count < 16 && i < un.size(); ++i,++count);
        total_count += count;
        compressed.push_back(ch | ((count-1) << 4));
    }
    return compressed;
}

std::string level_label(int i) {
    return "level_" + std::to_string(i + 1);
}

void write_levels(char const* filename, std::vector<grid_t> levels,
                  bool reversed = false) {
    std::ofstream outfile(filename);
    if(!outfile.is_open()) {
        std::fprintf(stderr, "unable to open file: \"%s\"\n", filename);
        throw EXIT_FAILURE;
    }

    outfile << ".include \"src/globals.inc\"\n";
    outfile << "num_levels = " << levels.size() << '\n';
    outfile << ".segment \"RODATA\"\n\n";
    outfile << "level_index:";
    for(int i = 0; i != levels.size(); ++i) {
        if(i % 4 == 0)
            outfile << "\n.dbyt ";
        else
            outfile << ',';
        outfile << level_label(i);
    }
    outfile << "\n\n";

    coord_t prev_door;
    for(int i = 0; i != levels.size(); ++i) {
        std::string error_prefix = "level " + std::to_string(i+1);


        outfile << level_label(i) << ":\n";

        coord_t ralph = get_1_object(levels[i], ralph_char, error_prefix);
        if(ralph == coord_t{0})
            throw std::runtime_error(error_prefix + ": missing ralph");
        outfile << "; Ralph start position:\n";
        outfile << ".byt " << compress_xy(ralph) << '\n';

        coord_t exit = get_1_object(levels[i], '"', error_prefix);
        if(exit == coord_t{0})
            throw std::runtime_error(error_prefix + ": missing exit");

        if(i > 0 && ((reversed && exit != prev_door)
                     || (!reversed && ralph != prev_door))) {
            throw std::runtime_error(
                error_prefix + ": entry/exit mismatch");
        }
        if(reversed)
            prev_door = ralph;
        else
            prev_door = exit;


        coord_t gem = get_1_object(levels[i], '\'', error_prefix);
        outfile << "; Gem position:\n";
        outfile << ".byt " << compress_xy(gem) << '\n';

        std::vector<enemy_t> enemies = extract_enemies(levels[i],
                                                       error_prefix);
        if(enemies.size() > 16)
            throw std::runtime_error(error_prefix + ": too many enemies");
        outfile << "; Num enemies:\n";
        outfile << ".byt " << enemies.size() << '\n';
        if(enemies.size() > 0) {
            outfile << "; Enemy attributes array:\n.byt ";
            for(int i = 0; i != enemies.size(); ++i) {
                if(i != 0)
                    outfile << ',';
                outfile << enemies[i].attr;
            }
            outfile << '\n';
            outfile << "; Enemy positions:\n.byt ";
            for(int i = 0; i != enemies.size(); ++i) {
                if(i != 0)
                    outfile << ',';
                outfile << compress_xy(enemies[i].pos);
            }
            outfile << '\n';
        }

        // Read tiles and compress them
        std::vector<unsigned char> compressed_tiles
            = compress_tiles(get_uncompressed_tiles(levels[i], error_prefix,
                                                    i, levels.size()));
        // Write tiles
        outfile << "; Tiles:\n";
        for(int i = 0; i != compressed_tiles.size(); ++i) {
            if(i % 16 == 0)
                outfile << "\n.byt ";
            else
                outfile << ',';
            outfile << (int)compressed_tiles[i];
        }
        outfile << '\n';
    }
}

std::vector<std::string> read_lines(char const* filename) {
    std::ifstream infile(filename);
    if(!infile.is_open()) {
        std::fprintf(stderr, "unable to open file: \"%s\"\n", filename);
        throw EXIT_FAILURE;
    }
    std::string line;
    std::vector<std::string> lines;
    while(std::getline(infile, line))
        lines.push_back(line);
    return lines;
}

int main(int argc, char** argv) {
    if(argc != 3) {
        std::fprintf(stderr, "usage: levelc [file]\n");
        return EXIT_FAILURE;
    }

    std::vector<grid_t> levels;

    char* const in_filename = argv[1];
    char* const out_filename = argv[2];
    std::vector<std::string> lines = read_lines(in_filename);
    std::reverse(lines.begin(), lines.end());
    int line_number = 1;

    while(!lines.empty() && lines.back().empty()) {
        lines.pop_back();
        ++line_number;
    }

    while(lines.size() >= H) {
        grid_t new_level;
        for(int i = 0; i != H; ++i, ++line_number) {
            if(lines.back().length() < W) {
                std::fprintf(stderr, "parse error; line %i too short\n", 
                             line_number);
                return EXIT_FAILURE;
            }
            std::copy(lines.back().begin(), lines.back().end(),
                      new_level[i].begin());
            lines.pop_back();
        }
        levels.push_back(new_level);

        while(!lines.empty() && lines.back().empty()) {
            lines.pop_back();
            ++line_number;
        }
    }

    if(lines.size() > 1) {
        std::fprintf(stderr, "incomplete level at end\n");
        return EXIT_FAILURE;
    }

    // Set this to true to make testing levels easier.
    constexpr bool reverse = 0;
    if(reverse)
        std::reverse(levels.begin(), levels.end());
    write_levels(out_filename, levels, reverse);

    std::printf("finished!\n");
}
