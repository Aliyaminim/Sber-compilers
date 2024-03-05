#!/bin/bash
mkdir -p build
cd build
flex ../lexer.l
g++ -O2 lex.yy.cc -o lexer

