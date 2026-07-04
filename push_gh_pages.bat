@echo off
REM Publica export\web\ como rama gh-pages en GitHub.
REM Ejecutar desde la raiz del repo DESPUES de exportar desde Godot.

setlocal

REM Verificar que estamos en la raiz del repo
if not exist "godot\project.godot" (
    echo ERROR: Ejecuta este script desde la raiz del repo.
    pause
    exit /b 1
)

REM Verificar que el export existe
if not exist "export\web\index.html" (
    echo ERROR: No se encontro export\web\index.html
    echo Primero ejecuta godot\export_web.bat para generar el export.
    pause
    exit /b 1
)

echo Publicando export\web\ en la rama gh-pages...
echo.

REM Asegurarse de que todos los cambios esten commiteados
git status --short
echo.

git add export\web\
git add godot\ .gitignore
git status --short

echo.
set /p CONFIRM="Hacer commit y push a gh-pages? (s/n): "
if /i not "%CONFIRM%"=="s" (
    echo Cancelado.
    pause
    exit /b 0
)

REM Commit de los archivos de export en main
git commit -m "Fase 7: export web Godot para gh-pages" --allow-empty

REM Push del subtree export/web/ a la rama gh-pages
echo.
echo Subiendo export\web\ a rama gh-pages...
git subtree push --prefix export/web origin gh-pages

if %ERRORLEVEL% == 0 (
    echo.
    echo Publicado correctamente.
    echo.
    echo Ahora activa GitHub Pages:
    echo   1. GitHub repo ^> Settings ^> Pages
    echo   2. Source: Deploy from a branch
    echo   3. Branch: gh-pages  /  Folder: / (root)
    echo   4. Save
    echo.
    echo URL: https://gs127scouts.github.io/[nombre-del-repo]/
) else (
    echo.
    echo ERROR en el push. Posibles causas:
    echo  - No tienes acceso de escritura al repo remoto
    echo  - La rama gh-pages tiene historial incompatible (ver nota abajo)
    echo.
    echo Si es la primera vez y falla, prueba:
    echo   git push origin `git subtree split --prefix export/web HEAD`:gh-pages --force
)

pause
