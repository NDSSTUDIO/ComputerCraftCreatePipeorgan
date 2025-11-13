--[[
    ComputerCraftCreatePipeorgan Copyright (C) 2025  qingR

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://gnu.ac.cn/licenses/>.
--]]

-- 解码MIDI
local args = { ... }
cache = fs.open("cache", "w")
io.output()

if cache then
    print("")
end

function noteToRedstone(note,velocity)
    if velocity == 0 then
        local note = X
    end
    print(octave)
    local strengthMap = {
        X = 0, C = 1, ["C#"] = 2, D = 3, ["D#"] = 4,
        E = 5, F = 6, ["F#"] = 7, G = 8,
        ["G#"] = 9, A = 10, ["A#"] = 11, B = 12
    }
    return strengthMap[note]
end

-- 用于读取大端编码的多字节数字
local function readBigEndian(file, numBytes)
    local value = 0
    for i = 1, numBytes do
        local byte = file:read(1)
        if not byte then return nil end
        value = value * 256 + byte:byte()
    end
    return value
end

-- 解析MIDI可变长度数值
local function readVariableLength(file)
    local value = 0
    local byte
    repeat
        byte = file:read(1)
        if not byte then return nil end
        byte = byte:byte()
        value = value * 128 + bit32.band(byte, 0x7F)
    until bit32.band(byte, 0x80) == 0
    return value
end

-- 将MIDI音高数字转换为音符名（例如 60 -> "C4"）
local noteNames = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
local function midiToNoteName(pitch)
    octave = math.floor(pitch / 12) - 1
    local noteIndex = (pitch % 12) + 1 -- Lua 表索引从1开始
    return noteNames[noteIndex]
    --  .. octave
end

-- 主解码函数
local function decodeMidiFile(filename)
    local file = io.open(filename, "rb")
    if not file then
        print("Unable to open file: " .. filename)
        return
    end

    -- 检查文件头
    local header = file:read(4)
    if header ~= "MThd" then
        print("Not a valid MIDI file")
        file:close()
        return
    end

    local headerLength = readBigEndian(file, 4)
    local format = readBigEndian(file, 2)
    local numTracks = readBigEndian(file, 2)
    local timeDivision = readBigEndian(file, 2)

    print(string.format("MIDI format: %d, Number of tracks: %d, Time format: %d", format, numTracks, timeDivision))

    -- 遍历所有音轨
    for track = 1, numTracks do
        print("\n--- Analyze audio track " .. track .. " ---")
        local chunkType = file:read(4)
        if chunkType ~= "MTrk" then
            print("Audio Tracks " .. track .. " Formatted error")
            break
        end
        local trackLength = readBigEndian(file, 4)
        local trackEnd = file:seek() + trackLength

        local absoluteTime = 0 -- 当前音轨的绝对时间（以tick为单位）
        
        -- 解析音轨内的事件
        while file:seek() < trackEnd do
            local deltaTime = readVariableLength(file)
            if not deltaTime then break end
            absoluteTime = absoluteTime + deltaTime

            local eventByte = file:read(1)
            if not eventByte then break end
            local eventType = eventByte:byte()
            
            -- 处理音符开启事件 (0x9n, n为通道号)
            if eventType >= 0x90 and eventType <= 0x9F then
                local channel = bit32.band(eventType, 0x0F)
                local pitchByte = file:read(1)
                local velocityByte = file:read(1)
                if not pitchByte or not velocityByte then break end
                
                local pitch = pitchByte:byte()
                local velocity = velocityByte:byte()
                

                if velocity >= 0  then
                    local noteName = midiToNoteName(pitch)
                    local redstonenote = noteToRedstone(noteName,velocity)


                    cache.writeLine(math.floor(absoluteTime/args[2]) .. " " ..redstonenote .. " " .. octave + args[3])
                    print(string.format("Time: %d, Channel: %d, Note: %s (%d), Velocity: %d", absoluteTime, channel, noteName, pitch, velocity))

                end
            -- 其他事件处理
            else
                -- 处理元事件 (0xFF)
                if eventType == 0xFF then
                    local metaTypeByte = file:read(1)
                    if not metaTypeByte then break end
                    local metaType = metaTypeByte:byte()
                    local length = readVariableLength(file)
                    if not length then break end
                    file:seek("cur", length) -- 跳过元事件数据
                
                -- 处理系统独占信息 (0xF0 或 0xF7)
                elseif eventType == 0xF0 or eventType == 0xF7 then
                    local length = readVariableLength(file)
                    if not length then break end
                    file:seek("cur", length)
                
                -- 处理其他通道信息
                else
                    -- 程序改变事件 (0xC0-0xCF) 和通道压力事件 (0xD0-0xDF) 只有1个参数
                    local eventCategory = bit32.band(eventType, 0xF0)
                    if eventCategory == 0xC0 or eventCategory == 0xD0 then
                        file:read(1) -- 跳过1个字节的参数
                    else
                        -- 其他事件（音符关闭、控制改变等）有2个参数
                        file:read(2) -- 跳过2个字节的参数
                    end
                end
            end
        end
    end

    file:close()
end

print(args[1])
decodeMidiFile(args[1])
io.close()

shell.run("play" .. " \"" .. args[1] .. "\"")