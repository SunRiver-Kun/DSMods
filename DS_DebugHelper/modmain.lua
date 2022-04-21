GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

require("debughelpers")
require("debugtools")

local KLEI_DEBUGCOMMAND = [[
==================================================
c_godmode()、c_pos(inst)、 c_printpos(inst)、c_give(prfab,count=1)   
c_reset()   --重启游戏
c_tile()    --打印鼠标下的地皮 
c_find(prefab, radius=9001, inst=ThePlayer)
c_findnext(prefab, radius=9001, inst=ThePlayer)
c_findtag(tag, radius=9001, inst=ThePlayer)
c_gonext(name)  --c_goto(c_findnext(name))
c_speed(speed)  --设置player移速
c_move(inst=c_sel())    --移动物体到鼠标位置
c_goto(destinst, inst=ThePlayer)   --移动inst到destinst的位置
c_simphase(phase)   --GetWorld():PushEvent("phasechange", {newphase = phase})
c_anim(animname, loop=false)  --c_sel().AnimState:PlayAnimation(animname, loop)
]]

local SR_DEBUGCOMMAND = {}
local SR_TASKINTIMECOMMAND = {}
local DEFAULT_TASKTIME = 0.1

function AddCommand(fnname, fn, str)
    if fn then
        if GLOBAL.rawget(GLOBAL, fnname) then
            error("Client: This fnname is existed. " .. fnname) --当不开洞穴且开有Extension时，优先用服务器的
        else
            GLOBAL.global(fnname) --注册到global
            GLOBAL.rawset(GLOBAL, fnname, fn)
            SR_DEBUGCOMMAND[fnname] = str or ""
        end
    end
end

AddCommand("AddCommand", AddCommand)

function AddTaskInTimeCommand(fnname, fn, str, time)
    AddCommand(fnname, fn, str)
    SR_TASKINTIMECOMMAND[fnname] = time or DEFAULT_TASKTIME
end

AddCommand("AddTaskInTimeCommand", AddTaskInTimeCommand)

function ExecuteConsoleCommandInTime(fnstr, time)
    time = time or DEFAULT_TASKTIME
    GetPlayer():DoTaskInTime(time, function()
        ExecuteConsoleCommand(fnstr)
    end)
end

AddCommand("ExecuteConsoleCommandInTime", ExecuteConsoleCommandInTime)


AddClassPostConstruct("screens/consolescreen", function(screen)
    screen.Run = function(self)
        local fnstr = self.console_edit:GetString()
        SuUsedAdd("console_used")
        for k, v in pairs(SR_TASKINTIMECOMMAND) do
            if string.find(fnstr, k) then
                ExecuteConsoleCommandInTime(fnstr, v)
                return
            end
        end
        ExecuteConsoleCommand(fnstr)
    end
end)

--添加官方代码
AddCommand("c_reset", function()
    StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot() })
end, "重新加载")
AddCommand("c_help", function()
    nolineprint(KLEI_DEBUGCOMMAND)
end, "打印c开头代码的帮助")

AddCommand("s_component", function(comp) DumpComponent(comp) end, "comp: component,打印组件")
AddCommand("s_entity", function(ent) DumpEntity(ent) end, "ent: inst, 打印实体,如: s_entity(GetPlayer())")
AddCommand("s_upvalues", function(func) DumpUpvalues(func) end, "func: function, 打印函数的upvalues")
AddCommand("s_nextphase", function() GetClock():NextPhase() end, "跳到下一个时间段")

AddCommand("cls", function ()
    local list = GetConsoleOutputList() 
    table.clear(list)
    TheFrontEnd:UpdateConsoleOutput()
end,"清屏")

local helpstr = nil
AddCommand("s_help", function()
    nolineprint("==================================================")
    for k, v in pairs(SR_DEBUGCOMMAND) do
        if v ~= "" then
            nolineprint(k.."\t"..v)
        end
    end
end, "打印帮助")

AddCommand("s_get", function()
    local inst = TheInput:GetWorldEntityUnderMouse()
    if inst then s_say(inst.prefab) end
    c_select(inst)
    return c_sel()
end, "返回鼠标下的物体，并设置调试物体")

AddCommand("s_inst", function()
    return c_sel()
end, "返回调试物体")

AddCommand("s_say", function(str)
    GetPlayer().components.talker:Say(tostring(str))
end, "str:any, 人物说话")

AddCommand("s_print", function(...)
    local tb = { ... }
    if #tb < 1 then nolineprint("s_print: nil") return end
    for _, v in ipairs(tb) do
        nolineprint("s_print: " .. tostring(v))
        if type(v) == "table" then
            for key, value in pairs(v) do
                nolineprint("\t" .. key, value)
            end
        end
    end
end, "..., 打印信息")

AddCommand("s_fn", function(fn)
    local tb = debug.getinfo(fn, "S")
    if tb == nil then nolineprint("s_fn fails to get the info of fn") return end
    nolineprint(fn, tb.what, tb.short_src)
end, "fn:function, 打印一个函数的来源")


local lastui = nil
AddTaskInTimeCommand("s_getui", function()
    lastui = TheFrontEnd:GetFocusWidget()
    if lastui then
        s_say(lastui.name or lastui)
    end
    return lastui
end, "返回当前鼠标下的UI")

AddTaskInTimeCommand("s_ui", function()
    return lastui or s_getui()
end, "返回上一个获取的UI或鼠标下的UI")


--------------------------init
if GetModConfigData("AutoGodMode") then
    AddPlayerPostInit(function(inst)
        inst:ListenForEvent("spawn", function(it, data)
            c_godmode()
            --------------
            AddCommand("ThePlayer", GetPlayer())
            AddCommand("TheWorld", GetWorld())
        end)
    end)
end


--------------------------test
AddCommand("s_test", function()
end)
