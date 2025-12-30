local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.5)

if _G.ExecutorKillStreakEffect_Instance and typeof(_G.ExecutorKillStreakEffect_Instance.Destroy) == "function" then
    pcall(_G.ExecutorKillStreakEffect_Instance.Destroy)
    task.wait(0.1)
end
_G.ExecutorKillStreakEffect_Instance = nil

_G.ExecutorKillStreakEffect = _G.ExecutorKillStreakEffect or {}
local KS = _G.ExecutorKillStreakEffect
local BASE_NAME = "ExecutorKillStreakEffect_Adapted_v5"

KS.Settings = KS.Settings or {
    DisplayText = "2"
}
local Settings = KS.Settings

KS.State = KS.State or {
    isEnabled = false,
    isInitialized = false,
    isWindowFocused = true,
    connections = {},
    billboard = nil,
    clonedFrame = nil,
    character = nil,
    originalKillstreakFrame = nil,
    originalGameBillboardGui = nil,
    originalBillboardMonitorConn = nil
}
local State = KS.State

local STUDS_OFFSET_Y = 0.1
local FIND_TIMEOUT = 10
local DEBUG_MODE = false

local function log(message) if DEBUG_MODE then end end
local function warnLog(message) end

local function Cleanup_Internal()
    log("Cleanup_Internal START")

    if State.originalBillboardMonitorConn and State.originalBillboardMonitorConn.Connected then
        State.originalBillboardMonitorConn:Disconnect()
        log("Мониторинг оригинального BillboardGui отключен.")
    end
    State.originalBillboardMonitorConn = nil

    for key, conn in pairs(State.connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
        State.connections[key] = nil
    end
    log("Пользовательские события отключены.")

    if State.billboard and State.billboard.Parent then
        State.billboard:Destroy()
        log("Наш BillboardGui удален.")
    end
    State.billboard = nil
    State.clonedFrame = nil

    if State.originalGameBillboardGui and State.originalGameBillboardGui.Parent then
        log("Попытка включить оригинальный игровой BillboardGui...")
        pcall(function() State.originalGameBillboardGui.Enabled = true end)
    end

    State.character = nil

    log("Cleanup_Internal END")
end

local function findOriginalUIElements_Internal()
    if State.originalKillstreakFrame and State.originalGameBillboardGui then
        log("Оригинальные элементы уже найдены.")
        return true
    end

    log("Поиск оригинальных UI элементов...")
    local success = pcall(function()
        local cutscenesFolder = Workspace:WaitForChild("Cutscenes", FIND_TIMEOUT)
        local billboardContainer = cutscenesFolder:WaitForChild("Billboard", FIND_TIMEOUT)
        local killstreakObject = billboardContainer:WaitForChild("Killstreak", FIND_TIMEOUT)
        State.originalKillstreakFrame = killstreakObject:WaitForChild("Frame", FIND_TIMEOUT)
        State.originalGameBillboardGui = billboardContainer:FindFirstChild("BillboardGui")

        if not State.originalKillstreakFrame or not State.originalKillstreakFrame:IsA("Frame") then
            error("Не найден оригинальный Frame.")
        end
        log("Найден оригинальный Frame: " .. State.originalKillstreakFrame:GetFullName())

        if State.originalGameBillboardGui and State.originalGameBillboardGui:IsA("BillboardGui") then
            log("Найден оригинальный игровой BillboardGui: " .. State.originalGameBillboardGui:GetFullName())
        else
            log("Оригинальный игровой BillboardGui не найден (не критично, но не сможем отключить).")
            State.originalGameBillboardGui = nil
        end
    end)

    if not success then
        warnLog("Ошибка при поиске оригинальных UI элементов.")
        State.originalKillstreakFrame = nil
        State.originalGameBillboardGui = nil
        return false
    end
    return true
end

local function forceVisible(guiObject)
    if not guiObject then return end
    if guiObject:IsA("GuiObject") then guiObject.Visible = true end
    if guiObject:IsA("ParticleEmitter") or guiObject:IsA("Beam") or guiObject:IsA("Trail") or guiObject:IsA("Light") then guiObject.Enabled = true end
    for _, child in ipairs(guiObject:GetChildren()) do forceVisible(child) end
end

local function Initialize_Internal()
    if State.isInitialized then return true end
    if not Player then warnLog("LocalPlayer не найден."); return false end
    local playerGui = Player:FindFirstChild("PlayerGui")
    if not playerGui then warnLog("PlayerGui не найден."); return false end

    log("Initialize_Internal START")

    if not findOriginalUIElements_Internal() then
        warnLog("Не удалось найти оригинальные элементы для инициализации.")
        return false
    end

    local success, newBillboard = pcall(function()
        local bb = Instance.new("BillboardGui")
        bb.Name = BASE_NAME .. "_Billboard"
        bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.Enabled = false; bb.ResetOnSpawn = false

        local originalBillboardParent = State.originalKillstreakFrame:FindFirstAncestorWhichIsA("BillboardGui")
        if originalBillboardParent then
            bb.Size = originalBillboardParent.Size
            bb.StudsOffset = originalBillboardParent.StudsOffset + Vector3.yAxis * STUDS_OFFSET_Y
        else
            bb.Size = UDim2.new(4, 0, 2, 0)
            bb.StudsOffset = Vector3.new(0, STUDS_OFFSET_Y, 0)
        end

        local clonedFrame = State.originalKillstreakFrame:Clone()
        clonedFrame.Name = BASE_NAME .. "_FrameClone"
        local clonedTextLabel = clonedFrame:FindFirstChild("TextLabel", true)
        if clonedTextLabel and clonedTextLabel:IsA("TextLabel") then
            clonedTextLabel.Text = Settings.DisplayText
        end
        forceVisible(clonedFrame)
        clonedFrame.Parent = bb
        bb.Parent = playerGui

        return bb
    end)

    if not success or not newBillboard then
        warnLog("Не удалось создать наш Billboard/клон!", newBillboard)
        return false
    end

    State.billboard = newBillboard
    State.clonedFrame = newBillboard:FindFirstChild(BASE_NAME .. "_FrameClone")
    log("Наш UI успешно создан.")

    if State.originalGameBillboardGui and State.originalGameBillboardGui.Parent then
        log("Отключение оригинального игрового BillboardGui...")
        State.originalGameBillboardGui.Enabled = false

        local conn = State.originalGameBillboardGui:GetPropertyChangedSignal("Enabled"):Connect(function()
            if State.originalGameBillboardGui and State.originalGameBillboardGui.Enabled == true then
                log("Обнаружено включение оригинального BillboardGui. Принудительно отключаем...")
                task.wait()
                if State.originalGameBillboardGui then State.originalGameBillboardGui.Enabled = false end
            end
        end)
        State.originalBillboardMonitorConn = conn
        log("Мониторинг оригинального BillboardGui запущен.")
    else
        log("Оригинальный игровой BillboardGui не найден/недоступен, пропускаем отключение/мониторинг.")
    end

    State.isInitialized = true
    log("Initialize_Internal SUCCESS")
    return true
end

local function UpdateAdornee(character)
    if not State.isInitialized or not State.billboard then return end

    State.character = character

    if State.isEnabled and character and character.Parent then
        local head = character:FindFirstChild("Head")
        if not head then task.wait(0.1); head = character:FindFirstChild("Head") end

        if head then
            log("Установка Adornee на голову: " .. head:GetFullName())
            State.billboard.Adornee = head
            State.billboard.Enabled = true
        else
            warnLog("Не найдена голова для " .. character.Name .. ". Наш UI будет скрыт.")
            State.billboard.Adornee = nil
            State.billboard.Enabled = false
        end
    else
        log("Персонаж отсутствует или скрипт выключен. Скрытие нашего UI.")
        if State.billboard then
             State.billboard.Adornee = nil
             State.billboard.Enabled = false
        end
    end
end

function KS:Enable()
    if State.isEnabled then return end
    log("Команда Enable...")
    State.isEnabled = true

    if not Initialize_Internal() then
        warnLog("Инициализация не удалась. Enable прервано.")
        State.isEnabled = false
        return
    end

    if not State.connections.CharacterAdded then
        State.connections.CharacterAdded = Player.CharacterAdded:Connect(function(char)
            log("Событие CharacterAdded: " .. char.Name)
            UpdateAdornee(char)
        end)
    end
    if not State.connections.CharacterRemoving then
        State.connections.CharacterRemoving = Player.CharacterRemoving:Connect(function(char)
            log("Событие CharacterRemoving: " .. char.Name)
            if State.character == char then UpdateAdornee(nil) end
        end)
    end

     if not State.connections.FocusLost then
        State.connections.FocusLost = UserInputService.WindowFocusReleased:Connect(function() State.isWindowFocused = false; UpdateAdornee(State.character) end)
     end
     if not State.connections.FocusGained then
        State.connections.FocusGained = UserInputService.WindowFocused:Connect(function() State.isWindowFocused = true; UpdateAdornee(State.character) end)
     end

    UpdateAdornee(Player.Character)

    log("Kill Streak Effect Включено.")
end

function KS:Disable()
    if not State.isEnabled then return end
    log("Команда Disable...")
    State.isEnabled = false

    if State.connections.CharacterAdded then State.connections.CharacterAdded:Disconnect(); State.connections.CharacterAdded = nil end
    if State.connections.CharacterRemoving then State.connections.CharacterRemoving:Disconnect(); State.connections.CharacterRemoving = nil end
    if State.connections.FocusLost then State.connections.FocusLost:Disconnect(); State.connections.FocusLost = nil end
    if State.connections.FocusGained then State.connections.FocusGained:Disconnect(); State.connections.FocusGained = nil end

    if State.billboard then
        State.billboard.Enabled = false
        State.billboard.Adornee = nil
    end

    if State.originalBillboardMonitorConn and State.originalBillboardMonitorConn.Connected then
        State.originalBillboardMonitorConn:Disconnect()
        log("Мониторинг оригинального BillboardGui остановлен (но оригинал остается выключенным).")
    end
    State.originalBillboardMonitorConn = nil

    log("Kill Streak Effect Выключено (UI и оригинал не тронуты, только скрыты/отключены события).")
end

function KS:UpdateSetting(settingName, value)
    if Settings[settingName] == nil then
        warnLog("Попытка обновить неизвестную настройку: " .. settingName)
        return
    end

    if settingName == "DisplayText" then
        if type(value) == "string" then
            Settings.DisplayText = value
            log("Настройка DisplayText обновлена на: '" .. value .. "'")
            if State.clonedFrame and State.clonedFrame.Parent then
                local textLabel = State.clonedFrame:FindFirstChild("TextLabel", true)
                if textLabel and textLabel:IsA("TextLabel") then
                    textLabel.Text = Settings.DisplayText
                    log("Текст в активном UI обновлен.")
                end
            end
        else
            warnLog("Неверный тип для DisplayText, ожидалась строка, получен: " .. type(value))
        end
    else
        warnLog("Попытка изменить нередактируемую настройку: " .. settingName)
    end
end

function KS:Destroy()
    log("Команда Destroy...")
    Cleanup_Internal()
    State.isEnabled = false
    State.isInitialized = false
    State.originalKillstreakFrame = nil
    State.originalGameBillboardGui = nil
    _G.ExecutorKillStreakEffect = nil
    _G.ExecutorKillStreakEffect_Instance = nil
    log("Полностью остановлен и удален.")
end

_G.ExecutorKillStreakEffect_Instance = KS

if not Player then
    warnLog("Не удалось получить LocalPlayer при инициализации скрипта. Destroy().")
    KS:Destroy()
    return
end