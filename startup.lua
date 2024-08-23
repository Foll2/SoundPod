local load = require("load")


-- Set the default palette colour # = 0x
term.setPaletteColour(colors.red, 0xcf4d4d)
term.setPaletteColour(colors.green, 0x4dcf4d)
term.setPaletteColour(colors.gray, 0x231c31)
term.setPaletteColour(colors.magenta, 0xCF4DBE)
term.setPaletteColour(colors.lightBlue, 0x4dbecf)

term.setBackgroundColour(colors.gray)


api = "https://api.prondrix.com/cc"

--Defaults

Loop = false
Cycle = false

Song_name = ""
Song_url = ""

input = 0

loadedSongs = {}

function songcontrolls()
    repeat
        term.clear()
        term.setCursorPos(1,1) 
        term.setTextColor(colors.lightBlue)

        --Write the currently playing song
        write("Currently Playing: \n")
        write(Song_name)
        write("\n")

        term.setTextColor(colors.magenta)

        write("Controls: \n")
        write("Q - Quit \n")
        if Loop then
            term.blit("1 - Loop","22222222","d7777777")
        else
            term.blit("1 - Loop","22222222","e7777777")
        end
        write("\n")

        if Cycle then
            term.blit("2 - Cycle","222222222","d77777777")
        else
            term.blit("2 - Cycle","222222222","e77777777")
        end
        write("\n\n")

        local _, key = os.pullEvent("key")
        if key == keys.one then
            Loop = not Loop
        elseif key == keys.two then
            Cycle = not Cycle
        end

    until key == keys.q

    term.clear()
    term.setCursorPos(1,1) 
    term.setTextColor(colors.lightBlue)
end

function playsong()
    first = true
    while first or Loop or Cycle do
        first = false
        if Cycle then
            input = input % #loadedSongs + 1
            Song_url = loadedSongs[input].url
            Song_name = loadedSongs[input].name
        end      
        shell.run("speaker play  "..Song_url) 
    end
end

function chooseSong(songs)
    write("Choose Song: ")
    input = read()
    if tostring(input) == "q" then
        return
    else
        input = tonumber(input)
    end
    if input and songs[input] then  
        Song_url = songs[input].url
        Song_name = songs[input].name
        parallel.waitForAny(songcontrolls, playsong)
    else
        term.setTextColor(colors.red)
        write("Invalid Song \n") 
    end
    sleep(1.5)
    term.clear()
    term.setCursorPos(1,1) 
end

function list(songs)
    write("No.   Song Name")
    write("---------------- \n")
    --write(string.format("%2d.   %s\n",0,"Exit "))    
    for count, song in pairs(songs) do
        write(string.format("%2d.   %s", count, song.name))
        write("\n")   
    end
end

function addsong()
    term.clear()
    term.setCursorPos(1,1)
    write("Input Youtube Url\n")
    write("> ")
    local yt_url = tostring(read())
    if tostring(yt_url) == "q" then
        return
    end
    write("\nAdding songs might take a while.\n")
    post = http.post { url = api.."/request", 
    body = '{"url": "'..yt_url..'"}',
    headers = {["Content-Type"] = "application/json"},
    timeout = 60} 
    if not post then
        term.clear()
        term.setCursorPos(1,1)
        write("Failed to add song")
        sleep(2)
        return
    end

    local response = post.readAll()
    local song = textutils.unserialiseJSON(response)
    if song.success then
        load.addSong(loadedSongs, song.name, song.url)
        loadedSongs = load.loadSongs() 
    else    
        term.clear()
        term.setCursorPos(1,1)
        write("Failed to add song")
        sleep(2)
    end
end

function changeorder()
    term.clear()
    term.setCursorPos(1,1)
    list(loadedSongs)
    write("\nInput song index to move\n")
    write("> ")
    local fromIndex = read()
    if tostring(fromIndex) == "q" then
        return
    else
        fromIndex = tonumber(fromIndex)
    end
    write("Input song index to move to\n")
    write("> ")
    local toIndex = tonumber(read())
    load.changeSongOrder(loadedSongs, fromIndex, toIndex)
    loadedSongs = load.loadSongs()
end

function changename()
    term.clear()
    term.setCursorPos(1,1)
    list(loadedSongs)
    write("Input song index to change name\n")
    write("> ")
    local index = read()
    if tostring(index) == "q" then
        return
    else
        index = tonumber(index)
    end
    write("Input new name\n")
    write("> ")
    local name = tostring(read())
    load.changeSongName(loadedSongs, loadedSongs[index].name, name)
    loadedSongs = load.loadSongs()
end

function deletesong()
    term.clear()
    term.setCursorPos(1,1)
    list(loadedSongs)
    write("Input song index to delete\n")
    write("> ")
    local index = read()
    if tostring(index) == "q" then
        return
    else
        index = tonumber(index)
    end
    load.deleteSong(loadedSongs, loadedSongs[index].name)
    loadedSongs = load.loadSongs()
end

function menu()
    write("Controls: \n")
    write("1 - Play Song \n")
    write("2 - Add Song \n")
    write("3 - Change Order \n")
    write("4 - Change Name \n") 
    write("5 - Delete Song \n")
    write("Press Q to exit a menu \n")

    write("\n> ")
    local m_input = tonumber(read()) 
    if m_input == 1 then
        term.clear()
        term.setCursorPos(1,1)
        list(loadedSongs)
        chooseSong(loadedSongs)
    elseif m_input == 2 then
        addsong()
    elseif m_input == 3 then
        changeorder()
    elseif m_input == 4 then
        changename()
    elseif m_input == 5 then
        deletesong()
    else
        term.setTextColor(colors.red)
        write("Invalid input")
        sleep(1.5)
        term.clear()
        term.setCursorPos(1,1)
    
    end

end
while true do
    loadedSongs = load.loadSongs()
    if loadedSongs then
        os.setComputerLabel("SoundPod V2.0")
        term.clear()
        term.setCursorPos(1,1)
        term.setTextColor(colors.magenta)
        write("SoundPod V2.0  by Foll \n")
        --Menu Controls

        term.setTextColor(colors.lightBlue)
        menu()
    else
        term.setTextColor(colors.red)
        write("No songs found")
        sleep(1.5)
        break
    end
end