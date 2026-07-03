@echo off
REM Exporta el juego a Web (HTML5) en modo headless.
REM Funciona con doble-click o desde cualquier directorio.

setlocal

REM Directorio donde vive este .bat (= carpeta godot\)
set BAT_DIR=%~dp0
REM Quitar la barra final
set BAT_DIR=%BAT_DIR:~0,-1%

REM Raiz del repo (un nivel arriba de godot\)
set REPO_ROOT=%BAT_DIR%\..

set GODOT_EXE=C:\Godot\Godot_v4.7-stable_win64.exe
set PROJECT_PATH=%BAT_DIR%
set EXPORT_PATH=%REPO_ROOT%\export\web\index.html

echo Proyecto: %PROJECT_PATH%
echo Salida:   %EXPORT_PATH%
echo.

if not exist "%GODOT_EXE%" (
    echo ERROR: No se encontro %GODOT_EXE%
    pause
    exit /b 1
)

if not exist "%REPO_ROOT%\export\web" mkdir "%REPO_ROOT%\export\web"

echo Exportando a Web...
"%GODOT_EXE%" --headless --path "%PROJECT_PATH%" --export-release "Web" "%EXPORT_PATH%"

set RESULT=%ERRORLEVEL%

if %RESULT% == 0 (
    echo.
    echo Exportacion completada. Archivos en export\web\:
    dir "%REPO_ROOT%\export\web\"
) else (
    echo.
    echo ERROR en la exportacion. Codigo: %RESULT%
)

pause
