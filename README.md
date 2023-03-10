# Get start with Conan
![Windows](https://img.shields.io/badge/windows-10-blue)
![Visual Studio](https://img.shields.io/badge/vs-2022-blue)  

Followed the YouTube tutorial of [@Lötwig Fusel](https://www.youtube.com/watch?v=T6RZ5On3xz8)  
github repo: https://github.com/Ohjurot/ConanPremakeTutorial
## 0. What does conan do?
[What is conan](https://docs.conan.io/2/introduction.html)  
**conan** is responsible for downloading, building and deploying all the libraries to our system and to output a file that basically tells our system the paths to binaries to the includes.  

**A Decentralized package manager**
<div align=center>
    <img src="figs/conan-systems.png" width=600>
</div>

<details>
Conan is a decentralized package manager with a client-server architecture. This means that clients can fetch packages from, as well as upload packages to, different servers (“remotes”), similar to the “git” push-pull model to/from git remotes.  
<br>  

At a high level, the servers are just storing packages. They do not build nor create the packages. The packages are created by the client, and if binaries are built from sources, that compilation is also done by the client application.

- `The Conan client`: this is a console/terminal command-line application, containing the heavy logic for package creation and consumption. Conan client has a local cache for package storage, and so it allows you to fully create and test packages offline. You can also work offline as long as no new packages are needed from remote servers.
- `JFrog Artifactory Community Edition (CE)` is the recommended Conan server to host your own packages privately under your control. It is a free community edition of JFrog Artifactory for Conan packages, including a WebUI, multiple auth protocols (LDAP), Virtual and Remote repositories to create advanced topologies, a Rest API, and generic repositories to host any artifact.
- `The conan_server` is a small server distributed together with the Conan client. It is a simple open-source implementation and provides basic functionality, but no WebUI or other advanced features.
- `ConanCenter` is a central public repository where the community contributes packages for popular open-source libraries like Boost, Zlib, OpenSSL, Poco, etc.

</details>

***
## Get start!
now we write a simple app that converts a string into hash. e.g.
```
>>>input
Hello World!
<<<output
0a75a91375b27d44
```

## 1. Create a `conanfile.txt`
To tell conan what to do. Fill up the dependency list i.e. the requirement.  
Go to https://conan.io/center/, search the library you need. Copy the library name at upleft in form of `LIBRARY/VERSION`

```
[requires]
xxhash/0.8.1
```
Conan will be resposible for:
- downloading, building and deploying all the libraries to our system 
- outputing a file that basically tells our OS the path to the .bin to the includes.

### Invoke a generator for `pre-make`
By default: a text generator, generates text file that's telling where all the files are, where all the includes are.

```
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
## Create premake
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

## 6. Build the project

now set the share mode in [options] of `conanfile.txt` as `False` so that we build a **static link** library. \rebuild the project, it already works.
```
[requires]
xxhash/0.8.1

[options]
xxhash:shared=False

[generators]
premake
```
## 7. Summary the commands into `configure.bat`
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

## 8. Build a dynamic link

### modify the `conanfile.txt`:
set the share mode as `True`, so that we build a **dynamic link** library:
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
xxhash:shared=True

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

## 9. Debug
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
