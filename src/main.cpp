#include <iostream>
#include <string>
#include <iomanip>

#include "xxhash.h"

int main()
{
    std::string userInput;
    uint64_t stringHash;

    // Let the user input a string
    std::cout << "Please input your string: ";
    std::cin >> userInput;

    // Hash the string
    stringHash = XXH64(userInput.c_str(), userInput.length(), 0);

    // Output the hash
    std::cout << "The Hash is: " << std::hex << std::setw(16) << std::setfill('0') << stringHash;
}