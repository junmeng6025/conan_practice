@echo off
REM Configure solution for release on vs2022
call "configure_release_vs2022.bat"
REM Build using MS Build tools
MsBuild StringHasher.sln