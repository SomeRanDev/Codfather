pushd .
cd %~dp0
call D:\Godot\4.3\Godot_v4.3-stable_win64_console.exe %1.tscn
call powershell -Command "& {[Console]::ResetColor()}"
popd