local uuh = "Foll2/SoundPod"
local dom = "https://github.com/"
shell.run("wget "..dom..uuh.."/raw/main/load.lua")
shell.run("wget "..dom..uuh.."/raw/main/startup.lua")
shell.run("startup")
shell.run("rm down.lua")