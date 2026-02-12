@echo off
REM .agent CLI Wrapper for Windows
REM This allows using: .\agent init instead of .\.agent\agent.ps1 init

set AGENT_DIR=%~dp0

if "%1"=="" (
    powershell -ExecutionPolicy Bypass -File "%AGENT_DIR%\agent.ps1"
) else (
    powershell -ExecutionPolicy Bypass -File "%AGENT_DIR%\agent.ps1" %*
)
