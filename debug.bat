@echo off
REM Conan dependency setup
conan install . --build missing -s build_type=Debug
REM Premake sln generation
"vendor/premake/premake5" vs2022