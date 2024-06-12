// 	lexer programm

%{
#include <stdio.h>
#include <string.h>
%}

%option noyywrap

%%
[ \t]+          { printf("Whitespace\n"); }
\n              { printf("Newline\n"); }
"if"|"else"|"while"|"for"|"int"|"float"|"char"|"return" { printf("Keyword: %s\n", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*  { printf("Identifier: %s\n", yytext); }
.               { printf("Character: %s\n", yytext); }
%%

int main() {
    char input[] = "if (x > 5) {\n\tprintf(\"Hello World!\");\n}\nelse {\n\tprintf(\"Goodbye!\");\n}";
    yy_scan_string(input); // Provide input string to the lexer
    yylex(); // Tokenize the input string
    return 0;
}


//// predective paring\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#include <iostream>
#include <vector>
#include <string>
#include <stack>
#include <sstream>
#include <unordered_map>

using namespace std;
unordered_map<string, unordered_map<string, vector<string>>> parsingTable = {
    {"E", {{"id", {"T", "E'"}}}},
    {"E'", {{"+", {"+", "T", "E'"}}, {"$", {"~"}}}}, 
    {"T", {{"id", {"id"}}}}
};
vector<string> tokenize(const string& input) {
    vector<string> tokens;
    stringstream ss(input);
    string token;
    while (ss >> token) {
        tokens.push_back(token);
    }
    tokens.push_back("$"); 
    return tokens;
}

bool parse(const vector<string>& tokens) {
    stack<string> parseStack;
    parseStack.push("$");
    parseStack.push("E");

    int index = 0;
    while (!parseStack.empty()) {
        string top = parseStack.top();
        string currentToken = tokens[index];

        if (top == currentToken) {
            parseStack.pop();
            index++;
        } else if (parsingTable.find(top) != parsingTable.end()) {
            if (parsingTable[top].find(currentToken) != parsingTable[top].end()) {
                parseStack.pop();
                vector<string> rule = parsingTable[top][currentToken];
                for (auto it = rule.rbegin(); it != rule.rend(); ++it) {
                    if (*it != "") { 
                        parseStack.push(*it);
                    }
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    return index == tokens.size();
}

int main() {
    string input;
    cout << "Enter the string to parse (tokens separated by spaces): ";
    getline(cin, input);

    vector<string> tokens = tokenize(input);
    bool result = parse(tokens);

    if (result) {
        cout << "The input string is successfully parsed!" << endl;
    } else {
        cout << "The input string is rejected by the parser!" << endl;
    }

    return 0;
}
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
******THREE ADRESS CODE***
#include<bits/stdc++.h>
using namespace std;
struct TAC {
    string op;
    string arg1;
    string arg2;
    string result;
};
string newTemp() {
    static int count = 0;
    return "t" + to_string(count++);
}
vector<TAC> generateTAC( string& expression, string& result) {
    vector<TAC> code;
    vector<string> tempStack;
    stringstream ss(expression);
    char token;
    while (ss >> token) {
        if (isdigit(token) || isalpha(token)) {
            tempStack.push_back(string(1, token));
        } else {
            string op2 = tempStack.back();
            tempStack.pop_back();
            string op1 = tempStack.back();
            tempStack.pop_back();
            string temp = newTemp();
            tempStack.push_back(temp);
            code.push_back({string(1, token), op1, op2, temp});
        }
    }
    result = tempStack.back();
    return code;
}
void printTAC(const vector<TAC>& code) {
    for (const auto& instr : code) {
        cout << instr.result << " = " << instr.arg1 << " " << instr.op << " " << instr.arg2 << endl;
    }
}

int main() {
    string expression;
    cout << "Enter a postfix arithmetic expression (e.g., ab+c*): ";
    cin >> expression;

    string result;
    vector<TAC> code = generateTAC(expression, result);
    
    cout << "\nThree-Address Code:\n";
    printTAC(code);
    
    return 0;
}
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
**********MACHINE CODE
#include <iostream>
#include <stack>

using namespace std;
int reg = 0;
struct Node {
    char data;
    Node* left;
    Node* right;
};
Node* createNode(char data) {
    Node* newNode = new Node();
    newNode->data = data;
    newNode->left = newNode->right = nullptr;
    return newNode;
}
int generateMachineCode(Node* root) {
    stack<int> machineStack;
    if (root) {
        if(root->data>='0' && root->data<='9'){
            cout << "LOAD R" << reg++ << ", " << root->data << "\n";
            return root->data-'0';
        }
        else{
        int leftResult = generateMachineCode(root->left);
        int rightResult = generateMachineCode(root->right);
        switch (root->data) {
            case '+':
                cout << "ADD R" << reg - 2 << ", R" << reg - 2 << ", R" << reg - 1 << endl;
                reg--; 
                return leftResult + rightResult;
            case '-':
                cout << "SUB R" << reg - 2 << ", R" << reg - 2 << ", R" << reg - 1 << endl;
                reg--; 
                return leftResult - rightResult;
            case '*':
                cout << "MUL R" << reg - 2 << ", R" << reg - 2 << ", R" << reg - 1 << endl;
                reg--; 
                return leftResult * rightResult;
            case '/':
                cout << "DIV R" << reg - 2 << ", R" << reg - 2 << ", R" << reg - 1 << endl;
                reg--; 
                return leftResult / rightResult;
            default:
                return root->data - '0'; 
        }
        }
        
    }
    return 0; 
}


int main() {
    // Example AST
    Node* root = createNode('+');
    root->left = createNode('3');
    root->right = createNode('*');
    root->right->left = createNode('4');
    root->right->right = createNode('5');

    // Generate machine code and get result
    int result = generateMachineCode(root);

    // Output result
    cout << "Result: " << result << endl;

    return 0;
}
