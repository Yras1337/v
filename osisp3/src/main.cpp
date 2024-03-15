#include <iostream>
#include <fstream>
#include <map>
#include <sstream>

using namespace std;

// Прямой фильтр: символы -> код Морзе
map<char, string> morseCode = {
    {'A', ".-"}, {'B', "-..."}, {'C', "-.-."}, {'D', "-.."}, {'E', "."}, {'F', "..-."},
    {'G', "--."}, {'H', "...."}, {'I', ".."}, {'J', ".---"}, {'K', "-.-"}, {'L', ".-.."},
    {'M', "--"}, {'N', "-."}, {'O', "---"}, {'P', ".--."}, {'Q', "--.-"}, {'R', ".-."},
    {'S', "..."}, {'T', "-"}, {'U', "..-"}, {'V', "...-"}, {'W', ".--"}, {'X', "-..-"},
    {'Y', "-.--"}, {'Z', "--.."},
    {'1', ".----"}, {'2', "..---"}, {'3', "...--"}, {'4', "....-"}, {'5', "....."},
    {'6', "-...."}, {'7', "--..."}, {'8', "---.."}, {'9', "----."}, {'0', "-----"}
};

// Обратный фильтр: код Морзе -> символы
map<string, char> reverseMorseCode;

void initializeReverseMorseCode() {
    for (auto& pair : morseCode) {
        reverseMorseCode[pair.second] = pair.first;
    }
}

// Функция для преобразования текста в код Морзе
string textToMorse(const string& text) {
    stringstream result;
    for (char c : text) {
        if (morseCode.find(toupper(c)) != morseCode.end()) {
            result << morseCode[toupper(c)] << " ";
        }
    }
    return result.str();
}

// Функция для преобразования кода Морзе в текст
string morseToText(const string& morse) {
    stringstream result;
    stringstream morseStream(morse);
    string morseCharacter;
    while (morseStream >> morseCharacter) {
        if (reverseMorseCode.find(morseCharacter) != reverseMorseCode.end()) {
            result << reverseMorseCode[morseCharacter];
        } else {
            result << "[UNKNOWN]";
        }
    }
    return result.str();
}

int main() {
    initializeReverseMorseCode();

    string inputFile = "input.txt";
    string outputFileForward = "output_forward.txt";
    string outputFileReverse = "output_reverse.txt";

    ifstream input(inputFile);
    ofstream outputForward(outputFileForward);
    ofstream outputReverse(outputFileReverse);

    if (!input.is_open() || !outputForward.is_open() || !outputReverse.is_open()) {
        cerr << "Failed to open files." << endl;
        return 1;
    }

    // Прямое преобразование текста в код Морзе
    string line;
    while (getline(input, line)) {
        outputForward << textToMorse(line) << endl;
    }

    // Обратное преобразование кода Морзе в текст
    input.clear();
    input.seekg(0);
    while (getline(input, line)) {
        outputReverse << morseToText(line) << endl;
    }

    cout << "Conversion completed successfully." << endl;

    input.close();
    outputForward.close();
    outputReverse.close();

    return 0;
}
