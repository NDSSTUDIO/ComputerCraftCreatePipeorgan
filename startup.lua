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

local args = { ... }

-- 显示器
monitors = { peripheral.find("monitor") }
print(monitors[1])
print(monitors[2])
monitor_a = monitors[1]
monitor_b = monitors[2]

-- 磁盘驱动器
drives = { peripheral.find("drive") }
print("drives[1]")
drive = drives[1]

playPercent = 100

monitor_a.setTextScale(1)
monitor_a.clear()
monitor_a.setTextColor(colors.yellow)  

monitor_b.setTextScale(1)
monitor_b.clear()
monitor_b.setTextColor(colors.yellow)  

b_width,b_hight = monitor_b.getSize()
a_width,a_hight = monitor_a.getSize()

local fs = _G.fs

startmessage1 = "ComputerCraft Create PipeOrgan Ver.1.0"
startmessage2 = "2025.10.26"
startmessage3 = "17ik0.CC"

function startmessage()
    os.sleep(1)
    monitor_b.setBackgroundColour(colors.yellow)
    monitor_a.setBackgroundColour(colors.yellow)
    monitor_a.clear()
    monitor_b.clear()
    os.sleep(0.1)
    monitor_b.setBackgroundColour(colors.black)
    monitor_a.setBackgroundColour(colors.black)
    monitor_a.clear()
    monitor_b.clear()



    monitor_a.setCursorPos((a_width / 2) - (#startmessage1 / 2), 2)
    monitor_a.write(startmessage1)
    monitor_a.setCursorPos((a_width / 2) - (#startmessage2 / 2), 3)
    monitor_a.write(startmessage2)
    monitor_a.setCursorPos((a_width / 2) - (#startmessage3 / 2), 4)
    monitor_a.write(startmessage3)


    monitor_b.setCursorPos((b_width / 2) - (#startmessage1 / 2), 2)
    monitor_b.write(startmessage1)
    monitor_b.setCursorPos((b_width / 2) - (#startmessage2 / 2), 3)
    monitor_b.write(startmessage2)
    monitor_b.setCursorPos((b_width / 2) - (#startmessage3 / 2), 4)
    monitor_b.write(startmessage3)

    os.sleep(2)
    button(monitor_a,a_width - 9,1,"","PL-AY","",0)
    os.sleep(0.1)
    button(monitor_a,a_width - 19,1,"","/-\\","",0)
    os.sleep(0.1)
    button(monitor_a,a_width - 29,1,"","\\-/","",0)
    os.sleep(0.1)
    button(monitor_a,a_width - 39,1,"/-\\","SPEED","\\-/",0)
    os.sleep(0.1)
    button(monitor_a,a_width - 49,1,"/-\\","OCT-AVE","\\-/",0)
    os.sleep(0.1)
    button(monitor_a,a_width - 59,1,"BA-SS","",bass_type,0)
    os.sleep(0.1)
    button(monitor_a,a_width - 69,1,"AT.LONG","",atl,0)
end




-- fslist扫描
function getFilesInDirectory(path)
    local files = {}
    -- 使用 fs.list 遍历目录
    for _, file in ipairs(fs.list(path)) do
        table.insert(files, file)
    end
    return files
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

-- 配置文件
function config()
        config_file = fs.open("button", "w")
        io.output()
        config_file.writeLine(0)
        config_file.writeLine("PAUSE")
        config_file.writeLine(1)
        config_file.writeLine(0)
        config_file.writeLine(bass_type)
        config_file.writeLine(atl)
        io.close()
        click = ""
end


-- 扫描文件列表
hasdisk = drive.isDiskPresent()
print(hasdisk)
if hasdisk == false then
    msg = "PLEASE INSERT DISK"
    monitor_a.clear()
    monitor_a.setCursorPos((a_width / 2) - (#msg / 2), 3)
    monitor_a.write(msg)
    monitor_b.clear()
    monitor_b.setCursorPos((a_width / 2) - (#msg / 2), 3)
    monitor_b.write(msg)
    os.pullEvent("disk")
end

mididirectory = drive.getMountPath()
print(mididirectory)

filesdirectory = mididirectory .. "/mid"

local fileList = getFilesInDirectory(mididirectory .. "/mid")



playspeed = 100
line = 1
octave = 0
atl = "TRE-BLE"
bass_type = "AU-TO"

stopbyprg = fs.open("stop", "r")
if not stopbyprg then
    startmessage()
else 
    shell.run("delete","stop")
    io.close()
end



monitor_a.clear()
monitor_b.clear()

while true do 

    -- 右屏幕列表
    monitor_b.clear()
    monitor_b.setTextScale(1)
    monitor_b.setCursorPos(2, 2)
    monitor_b.write("Select:")
    monitor_b.setCursorPos(2, 3)
    monitor_b.write(filesdirectory .. "/")
    monitor_b.setCursorPos(2, 4)
    monitor_b.write(fileList[line])

    --左屏幕
    monitor_a.clear()

    button(monitor_a,a_width - 9,1,"","PL-AY","",0)
    button(monitor_a,a_width - 19,1,"","/-\\","",0)
    button(monitor_a,a_width - 29,1,"","\\-/","",0)
    button(monitor_a,a_width - 39,1,"/-\\","SPEED","\\-/",0)
    button(monitor_a,a_width - 49,1,"/-\\","OCT-AVE","\\-/",0)
    button(monitor_a,a_width - 59,1,"BA-SS","",bass_type,0)
    button(monitor_a,a_width - 69,1,"ATSTOPS","",atl,0)

    -- 按钮事件触发器
    event,monitor_side,touch_x,touch_y = os.pullEvent("monitor_touch")
    

    button_click(a_width - 9,1,5,"play")
    button_click(a_width - 19,1,5,"up")
    button_click(a_width - 29,1,5,"down")
    button_click(a_width - 39,1,2,"speedup")
    button_click(a_width - 39,3,5,"speeddown")
    button_click(a_width - 49,1,2,"octaveup")
    button_click(a_width - 49,3,5,"octavedown")
    button_click(a_width - 59,1,5,"bass")
    button_click(a_width - 69,1,5,"at.long")
    
    print(click)

    -- 速度加
    if click == "speedup" then
        playspeed = playspeed + 10
        if #tostring(playspeed) == 2 then
            button(monitor_a,a_width - 39,1,"/-\\",tostring(playspeed) .. "%","\\-/",0)
        else
            button(monitor_a,a_width - 39,1,"/-\\",tostring(playspeed),"\\-/",0)
        end
        os.sleep(0.5)
    elseif click == "speeddown" then
        playspeed = playspeed - 10
        if #tostring(playspeed) == 2 then
            button(monitor_a,a_width - 39,1,"/-\\",tostring(playspeed) .. "%","\\-/",0)
        else
            button(monitor_a,a_width - 39,1,"/-\\",tostring(playspeed),"\\-/",0)
        end
        os.sleep(0.5)
    end


    -- 调
    if click == "octaveup" then
        octave = octave + 1

        button(monitor_a,a_width - 49,1,"/-\\",tostring(octave) .. " ","\\-/",0)

        os.sleep(0.5)
    elseif click == "octavedown" then
        octave = octave - 1

        button(monitor_a,a_width - 49,1,"/-\\",tostring(octave) .. " ","\\-/",0)

        os.sleep(0.5)
    end

    -- BASS
    if click == "bass" then
        if bass_type == "AU-TO" then
            bass_type = "MI-DI"
        else
            bass_type = "AU-TO"
        end
    end

    -- 长音
    if click == "at.long" then
        if atl == "TRE-BLE" then
            atl = "ALL"
        elseif atl == "ALL" then
            atl = "OFF"
        else
            atl = "TRE-BLE"
        end
    end

    -- 下一项
    if click == "down" then
        line = line + 1
        if line >= #fileList then 
            line = 1
        end
    end
    -- 上一项
    if click == "up" then
        line = line - 1
        if line == 0 then 
            line = #fileList
        end
    end
    -- play
    if click == "play" then
        config()
        shell.run("decode" .. " \"" .. filesdirectory .. "/" .. fileList[line] .. "\" " .. playspeed / 10 .. " " .. octave)
    end

    os.sleep()
end