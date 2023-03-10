@echo off
REM Conan dependency setup
conan install . --build missing
REM Premake sln generation
"vendor/premake/premake5" vs2022