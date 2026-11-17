@echo off
rem RadarSim.bat - double-click to build (if anything changed) and start the radar simulator.
rem Needs the .NET SDK (the same one "dotnet run --project gui" uses). The console window stays open while the
rem program runs and shows its log lines; close the radar window to stop it.
cd /d "%~dp0"
title Radar Sim
dotnet run --project gui -c Release
if errorlevel 1 (
    echo.
    echo The radar sim stopped with an error. Read the lines above.
    pause
)
