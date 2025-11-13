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


-- 播放解码后的乐谱(cache)
local args = { ... }
shell.run("fg","menu")

monitors = { peripheral.find("monitor") }
print(monitors[1])
print(monitors[2])
monitor_b = monitors[2]

playPercent = 100

os.sleep(0.1)

monitor_b.setTextScale(1)
monitor_b.clear()
monitor_b.setTextColor(colors.yellow)



b_width,b_hight = monitor_b.getSize()

monitor_b.setCursorPos((b_width / 2) - (#args[1] / 2), 2)
monitor_b.write(args[1])

bass_type = 0
speed_tc = 1
timecode = 0
lineNumber = 1
octave_add = 0
atl = 0

local function progressbar(playPercent)
    monitor_b.setCursorPos(1, 1)
    -- 生成百分比字符串并替换空格为短横线
    local percentStr = "|" .. string.format("%3d%%", math.floor(playPercent)) .. "   "

    -- 计算进度条可用长度（总宽度减去百分比字符串长度）
    local barLength = b_width - #percentStr
    local barLength = math.max(barLength, 1)  -- 确保最小长度

    -- 计算箭头位置并限制范围
    local arrowPos = math.min(math.floor(barLength * playPercent / 100), barLength - 1)
    -- 构建进度条各部分
    local left = string.rep("=", arrowPos)
    local left2 = string.rep("/", arrowPos)
    local right = string.rep("-", barLength - arrowPos - 1)
    local right2 = string.rep(" ", barLength - arrowPos - 1)
    
    -- 组合最终显示内容
    monitor_b.setCursorPos(1, 3)
    monitor_b.write("  ".. left.."|"..right)

    monitor_b.setCursorPos(1, 4)
    monitor_b.write(" |".. left2.."|"..right2..percentStr)

    monitor_b.setCursorPos(1, 5)
    monitor_b.write("  ".. left.."|"..right)
end

function parseString(input)
    
    if input then
        local timecode_f, note, octave
    else
        return
    end
    -- 找到第一个空格的位置
    local first_space = string.find(input, " ")
    if first_space then
        timecode_f = string.sub(input, 1, first_space - 1)
        
        -- 找到第二个空格的位置（从第一个空格后开始找）
        local second_space = string.find(input, " ", first_space + 1)
        if second_space then
            note = string.sub(input, first_space + 1, second_space - 1)
            octave = string.sub(input, second_space + 1)
        end
    end
    
    return timecode_f, note, octave
end


-- 关闭所有输出
function redstone_out_off()
    redstone.setAnalogOutput("top",0)
    redstone.setAnalogOutput("left",0)
    redstone.setAnalogOutput("right",0)
end

-- 定义函数将文件所有行读入表
function readAllLines()
    local file = fs.open("cache", "r")
    if not file then
        return nil
    end

    local lines = {}
    while true do
        local line = file.readLine()
        if not line then break end
        table.insert(lines, line)
    end

    file.close()
    return lines
end


function do_button()
    local do_set = fs.open("button", "r")
    if not do_set then
        return
    end
    local set_lines = {}
    while true do
        local set_line = do_set.readLine()
        if not set_line then break end
        table.insert(set_lines, set_line)
    end
    if set_lines[1] == "1" then
        stop()
    end
    if set_lines[2] == "PAUSE." then
        playing = 0
    else 
        playing = 1
    end
    if set_lines[3] ~= "1" then
        speed_tc = tonumber(set_lines[3])
        if speed_tc ~= tonumber(set_lines[3]) then
            redstone_out_off()
        end
    else 
        speed_tc = 1
        if speed_tc ~= tonumber(set_lines[3]) then
            redstone_out_off()
        end
    end
    if set_lines[4] ~= "0" then
        octave_add = tonumber(set_lines[4])
    else 
        octave_add = 0
    end
    if set_lines[5] == "MI-DI" then
        if bass_type ~= 0 then
            redstone_out_off()
        end
        bass_type = 0
    else
        if bass_type ~= 1 then
            redstone_out_off()
        end
        bass_type = 1
    end
    if set_lines[6] == "TRE-BLE" then
        atl = 1
    elseif set_lines[6] == "ALL" then
        atl = 2
    else 
        atl = 0 
    end
    do_set.close()
    --print("do-set")
end


-- 演奏
function donote()
    while math.floor(tonumber(timecode)) >= tonumber(timecode_f) do
        
        if atl == 2 then
            redstone.setAnalogOutput("top",0)
            redstone.setAnalogOutput("left",0)
            redstone.setAnalogOutput("right",0)
        end

        octave = tonumber(octave) + octave_add
        
        

        if 3 >= octave then -- 低音
        redstone.setAnalogOutput("top",tonumber(note))
        
        elseif octave >= 4 and bass_type == 1 then
           redstone.setAnalogOutput("top",tonumber(note))
        end
        
        if octave == 4 then -- 中音
            if atl == 1 then
                redstone.setAnalogOutput("right",0)
            end
            redstone.setAnalogOutput("left",tonumber(note))
        end

        if octave >= 5 then -- 高音
            if atl == 1 then
                redstone.setAnalogOutput("left",0)
            end
            redstone.setAnalogOutput("right",tonumber(note))
        end

        lineNumber = lineNumber + 1
        timecode_f, note, octave = parseString(allLines[lineNumber])
    end
end

-- 停止播放时
function stop()
    fs.open("stop", "w")
    io.close()
    os.reboot()
end

allLines = readAllLines()



local function play()
    term.clear()
    print(lineNumber,"/",#allLines)
    print(timecode)
    print("timecode_f:", timecode_f,"note:",note,"octave",octave)
    print("SPEED:" .. speed_tc .. "octave_add:" .. octave_add)
    --print(timecode / end_tc)
    progressbar(math.floor(timecode) / end_tc * 100)

    donote()
    timecode = timecode + speed_tc

end

-- 进度条计算

timecode_f, note, octave = parseString(allLines[(#allLines)])
end_tc = tonumber(timecode_f)

-- 第一次获取
timecode_f, note, octave = parseString(allLines[lineNumber])


playing = 1

while (true)
do
    if math.floor(timecode) / 20 == math.floor(timecode / 20) then
        do_button()
    end

    if playing == 1 and tonumber(end_tc) >= timecode then
        play()
    end
    if timecode >= tonumber(end_tc) then
        playing = 0
        os.sleep(0.6)
        redstone.setAnalogOutput("top",0)
        redstone.setAnalogOutput("left",0)
        redstone.setAnalogOutput("right",0)
        stop()
    end
    if playing == 0 then
        redstone.setAnalogOutput("top",0)
        redstone.setAnalogOutput("left",0)
        redstone.setAnalogOutput("right",0)
    end


    os.sleep(0)
end
