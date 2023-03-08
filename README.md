# Get start with Conan
Followed the YouTube tutorial of [@Lötwig Fusel](https://www.youtube.com/watch?v=T6RZ5On3xz8)  
github repo: https://github.com/Ohjurot/ConanPremakeTutorial
## 1. Create a `conanfile.txt`
To tell conan what to do. Fill up the dependency list i.e. the requirement.  
Go to https://conan.io/center/, search the library you need. Copy the library name at upleft in form of `LIBRARY/VERSION`

```txt
[requires]
xxhash/0.8.1
```
Conan will be resposible for:
- downloading, building and deploying all the libraries to our system 
- outputing a file that basically tells our OS the path to the .bin to the includes.

### Invoke a generator for `pre-make`
By default: a text generator, generates text file that's telling where all the files are, where all the includes are.

```txt
[requires]
xxhash/0.8.1

[generators]
premake
```

## 2. Install the required libraries with `conanfile.txt`
open a `cmd prompt` in VSCode, directed to current path automatically.
```bash
conan install .
```
to remove library by name
```bash
conan remove <lib_name>
```

### Possible ERROR: missing prebuilt package
```bash
conan install . --build missing
```
to tell conan to build whatever missed according to downloaded recipe, which invoked VS compiler and build on our own sys

### What we get after conan install:
- conanfile.txt
- conaninfo.txt
- conanbuildinfo.txt
- conan.lock
- conanbuildinfo.premake.lua
- graph_info.json

in `.gitignore`:
```txt
# Exclude conan-generated files
conan.lock
conanbuildinfo**
conaninfo.txt
graph_info.json
```
### What we need now:
- src
- the pre-made .exe and other pre-made stuff

## 3. create `src` folder
to hold `main.cpp` and other scripts
## 4. create `premake5.lua`
the file that helps to generate data, syntax like this:
```lua
-- Include conan gennerate script
include("conanbuildinfo.premake.lua")

-- Main Workspace
workspace "StringHasher"
    -- Import conan gennerate config
    conan_basic_setup()

    -- Project
    project "StrH64"
        kind "ConsoleApp"
        language "C++"
        targetdir "bin/%{cfg.buildcfg}"
		objdir "bin/%{cfg.buildcfg}/obj/"
		location "src"
        debugdir "app"

        linkoptions { conan_exelinkflags }

        files { "**.h", "**.cpp" }

        filter "configurations:Debug"
		defines { "DEBUG" }
		symbols "On"

		filter "configurations:Release"
		defines { "NDEBUG" }
		optimize "On"
```
## 4. Create premake
new folder
```bash
/vendor/premake5
```
in there, we have
- premake5.exe
- premake5.LICENSE.txt

## 5. Generate the VS needed files
```bash
"vendor/premake/premake5" vs2022
```
this would generate
- StringHasher.sln
- /src/StrH64.vcxproj
- /src/StrH64.vcxproj.user

since they are also generated files, they should be ignored by git:
```txt
# .gitignore

# Exclude conan-generated files
conan.lock
conanbuildinfo**
conaninfo.txt
graph_info.json

# Exclude vs stuff
*.sln
*.vcxproj
*.vcxproj.user
.vs
```

## 6. The `main.cpp`
```cpp
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
```
now set the share mode in [options] of `conanfile.txt` as False, rebuild the project, it already works.
```
[requires]
xxhash/0.8.1

[options]
xxhash:shared=False

[generators]
premake
```
### Summary the commands into `configure.bat`
... so that we can do the rebuild commands in one line:
```bat
@echo off
REM Conan dependency setup
conan install . --build missing
REM Premake sln generation
"vendor/premake/premake5" vs2022
```
run
```bash
configure.bat
```
then build the project, it can run without issue

## 7. Build

### modify the `conanfile.txt`:
set the share mode as True:
```
[requires]
xxhash/0.8.1

[options]
xxhash:shared=True

[generators]
premake
```
When shared set as "True", there commes issue. So we need to tell conan that we want to copy binaries by defining imports:
```
[requires]
xxhash/0.8.1

[options]
xxhash:shared=True  # or False

[imports]
bin, *.dll -> ./app

[generators]
premake
```
the rerun the build process
```bash
configure.bat
```

edit `.gitignore` again to exclude generated stuffs:
```txt
# .gitignore

# Exclude conan-generated files
conan.lock
conanbuildinfo**
conaninfo.txt
graph_info.json
conan_imports_manifest.txt


# Exclude vs stuff
*.sln
*.vcxproj
*.vcxproj.user
.vs

# Exclude binaries
bin
app/*.dll
```

## 8. Debug
create `configure_debug.bat`:
```bat
@echo off
REM Conan dependency setup
conan install . --build missing -s build_type=Debug
REM Premake sln generation
"vendor/premake/premake5" vs2022
```

create `build.bat`
```bat
@echo off
REM Configure solution for release on vs2022
call "configure_release_vs2022.bat"
REM Build using MS Build tools
MsBuild StringHasher.sln
```