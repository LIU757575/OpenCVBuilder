:: build opencv 4 for windows with multi-config support (Debug/Release/RelWithDebInfo)
@ECHO OFF
chcp 65001
cls
SETLOCAL EnableDelayedExpansion

IF "%1"=="" (
    echo input VS_VER none, use v142
    set VS_VER="v142"
) ELSE (
    echo input VS_VER:%1
    set VS_VER="%1"
)

IF "%2"=="" (
    echo input CRT none, use mt
    set CRT="mt"
) ELSE (
    echo input CRT:%2
    set CRT="%2"
)

IF "%3"=="" (
    echo input BUILD_TYPE none, use Release
    set BUILD_TYPE=Release
) ELSE (
    echo input BUILD_TYPE:%3
    set BUILD_TYPE=%3
)

for /f "Delims=" %%x in (opencv4_cmake_options.txt) do set OPTIONS=!OPTIONS! %%x

call :cmakeParams "x64" %VS_VER% %CRT% %BUILD_TYPE%
call :cmakeParams "Win32" %VS_VER% %CRT% %BUILD_TYPE%
GOTO:EOF

:cmakeParams
set "ARCH=%~1"
set "VS=%~2"
set "CRT_TYPE=%~3"
set "BUILD_TYPE=%~4"

mkdir "build-%ARCH%-%VS%-%CRT_TYPE%-%BUILD_TYPE%"
pushd "build-%ARCH%-%VS%-%CRT_TYPE%-%BUILD_TYPE%"

if "%CRT_TYPE%" == "md" (
    set STATIC_CRT_ENABLED=OFF
) else (
    set STATIC_CRT_ENABLED=ON
)

cmake -A "%ARCH%" -T "%VS%,host=x64" -DCMAKE_INSTALL_PREFIX=install ^
  -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
  -DBUILD_WITH_STATIC_CRT=%STATIC_CRT_ENABLED% %OPTIONS% ^
  ..

cmake --build . --config %BUILD_TYPE% -j %NUMBER_OF_PROCESSORS%
cmake --build . --config %BUILD_TYPE% --target install

popd
GOTO:EOF
