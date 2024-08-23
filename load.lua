local load = {}


function SaveSongs(songs)
    local file = io.open("songs.txt", "w")
    if file then
        for _, song in ipairs(songs) do
            file:write(song["name"] .. "£" .. song["url"] .. "\n")
        end
        file:close()
    end
end


function load.loadSongs()
    local songs = {}
    local file = io.open("songs.txt", "r")
    if file then
        for line in file:lines() do
            local name, url = line:match("([^£]+)£([^£]+)")
            table.insert(songs, { name = name, url = url })
        end
        file:close()
        return songs
    else
        file = io.open("songs.txt", "w")
        if file then
            file:close()
        else
            return nil
        end
        return songs
    end
end


function load.addSong(songs, newName, newUrl)
    table.insert(songs, { name = newName, url = newUrl })
    SaveSongs(songs)
end

function load.deleteSong(songs, songName)
    for i, song in ipairs(songs) do
        if song.name == songName then
            table.remove(songs, i)
            SaveSongs(songs)
            return
        end
    end
end

function load.changeSongName(songs, oldName, newName)
    for _, song in ipairs(songs) do
        if song.name == oldName then
            song.name = newName
            SaveSongs(songs)
            return
        end
    end
end


function load.changeSongOrder(songs, fromIndex, toIndex)
    local song = table.remove(songs, fromIndex)
    table.insert(songs, toIndex, song)
    SaveSongs(songs)
end


return load