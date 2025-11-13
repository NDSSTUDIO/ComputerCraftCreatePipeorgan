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


-- 并行play.lua的控制菜单
monitors = { peripheral.find("monitor") }
print(monitors[1])
print(monitors[2])
monitor_a = monitors[1]
monitor_b = monitors[2]
playPercent = 100

monitor_a.setTextScale(1)
monitor_a.clear()
monitor_a.setTextColor(colors.yellow)  


monitor_a.setCursorPos(1, 1)
monitor_a.write(" ComputerCraft Create Pipeoran Ver.1.0 Monitor A")


a_width,a_hight = monitor_a.getSize()

local fs = _G.fs

-- 读取配置
function config_read()
    set_file = fs.open("button", "r")
    local set_lines = {}
    while true do
        local set_line = set_file.readLine()
        if not set_line then break end
        table.insert(set_lines, set_line)
    end
    bass_type = set_lines[5]
    atl = set_lines[6]
    io.close()
end

-- 按钮
function button(display,x,y,text1,text2,text3,color_set)
    if color_set == 0 then 
        display.setTextColor(colors.yellow)
    else
        display.setTextColor(colors.gray)
    end

    -- 按钮外框
    display.setCursorPos(x, y)
    display.write(" ------- ")
    display.setCursorPos(x, y+1)
    display.write("|       |")
    display.setCursorPos(x, y+2)
    display.write("|       |")
    display.setCursorPos(x, y+3)
    display.write("|       |")
    display.setCursorPos(x, y+4)
    display.write(" ------- ")

    -- 按钮内容
    display.setCursorPos((x+4) - (#text1 / 2) + 1, y+1)
    display.write(text1)
    display.setCursorPos((x+4) - (#text2 / 2) + 1, y+2)
    display.write(text2)
    display.setCursorPos((x+4) - (#text3 / 2) + 1, y+3)
    display.write(text3)
    display.setTextColor(colors.yellow)

end
-- 按钮事件
function button_click(x,y,yu,name)   
    if monitor_side ~= "" then
        if touch_x >= x and x + 8 >= touch_x then
            if touch_y >= y and yu >= touch_y then
            monitor_a.setCursorPos(1, 1)
            button(monitor_a,x,1,"","","",1)
            click = name
            os.sleep(0.1)
            end
        end
    end
end


function config()
        file = fs.open("button", "w")
        io.output()
        file.writeLine(stop)
        file.writeLine(pause)
        file.writeLine(playspeed / 100)
        file.writeLine(octave)
        file.writeLine(bass_type)
        file.writeLine(atl)
        io.close()
        click = ""
end


playspeed = 100
line = 1
octave = 0
bass_type = "AU-TO"
monitor_a.clear()
pause = "PAUSE"
stop = 0
atl = "TRE-BLE"
click = ""
config_read()
config()

while true do 


    --左屏幕
    monitor_a.clear()

    button(monitor_a,a_width - 9,1,"","ST-OP","",0)
    button(monitor_a,a_width - 19,1,"",pause,"",0)
    button(monitor_a,a_width - 29,1,"/-\\","SPEED","\\-/",0)
    button(monitor_a,a_width - 39,1,"/-\\","OCT-AVE","\\-/",0)
    button(monitor_a,a_width - 49,1,"BA-SS","",bass_type,0)
    button(monitor_a,a_width - 59,1,"ATSTOPS","",atl,0)

    -- 按钮事件触发器
    event,monitor_side,touch_x,touch_y = os.pullEvent("monitor_touch")


    button_click(a_width - 9,1,5,"stop")
    button_click(a_width - 19,1,5,"pause")
    button_click(a_width - 29,1,2,"speedup")
    button_click(a_width - 29,3,5,"speeddown")
    button_click(a_width - 39,1,2,"octaveup")
    button_click(a_width - 39,3,5,"octavedown")
    button_click(a_width - 49,1,5,"bass")
    button_click(a_width - 59,1,5,"at.long")
    
    -- 速度加
    if click == "speedup" then
        playspeed = playspeed + 10
        if #tostring(playspeed) == 2 then
            button(monitor_a,a_width - 29,"/-\\",tostring(playspeed) .. "%","\\-/",0)
        else
            button(monitor_a,a_width - 29,1,"/-\\",tostring(playspeed),"\\-/",0)
        end
        os.sleep(0.2)
    end
    if click == "speeddown" then
        playspeed = playspeed - 10
        if #tostring(playspeed) == 2 then
            button(monitor_a,a_width - 29,1,"/-\\",tostring(playspeed) .. "%","\\-/",0)
        else
            button(monitor_a,a_width - 29,1,"/-\\",tostring(playspeed),"\\-/",0)
        end
        os.sleep(0.2)
    end


    -- 调
    if click == "octaveup" then
        octave = octave + 1

        button(monitor_a,a_width - 39,1,"/-\\",tostring(octave) .. " ","\\-/",0)

        os.sleep(0.2)
    end
    if click == "octavedown" then
        octave = octave - 1

        button(monitor_a,a_width - 39,1,"/-\\",tostring(octave) .. " ","\\-/",0)

        os.sleep(0.2)
    end

    -- BASS
    if click == "bass" then
        if bass_type == "AU-TO" then
            bass_type = "MI-DI"
        else
            bass_type = "AU-TO"
        end
    end

    -- PAUSE
    if click == "pause" then
        if pause == "PAUSE" then
            pause = "PAUSE."
        else 
            pause = "PAUSE"
        end
    end

    if click == "at.long" then
        if atl == "TRE-BLE" then
            atl = "ALL"
        elseif atl == "ALL" then
            atl = "OFF"
        else
            atl = "TRE-BLE"
        end
    end
    -- stop
    if click == "stop" then
        stop = 1
    end

    if click ~= "" then
        config()
    end
    os.sleep(0)
end