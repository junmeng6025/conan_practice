@echo off
REM fetch and compile external dependecys using conan
conan install . --build missing -s build_type=Debug
REM gennerate project using premake5
"./vendor/premake5/premake5" vs2022