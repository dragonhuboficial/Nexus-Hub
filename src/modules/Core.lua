local Core = {}

-- [ UTILITÁRIOS DE INSPEÇÃO PROFUNDA ]
local function getConstants(f)
    if not debug or not debug.getconstants then return {} end
    local constants = {}
    pcall(function()
        constants = debug.getconstants(f)
    end)
    return constants
end

local function getUpvalues(f)
    if not debug or not debug.getupvalues then return {} end
    local upvalues = {}
    pcall(function()
        upvalues = debug.getupvalues(f)
    end)
    return upvalues
end

function Core.hook(Nexus, UI, Decryption)
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if _G.NexusActive and (method == "FireServer" or method == "InvokeServer") then
            local caller = getcallingscript and getcallingscript() or nil
            local info = {}
            
            pcall(function()
                local dbgInfo = debug.getinfo(2)
                if dbgInfo and dbgInfo.func then
                    info.Constants = getConstants(dbgInfo.func)
                    info.Upvalues = getUpvalues(dbgInfo.func)
                    info.Source = dbgInfo.source
                    info.Line = dbgInfo.currentline
                end
            end)

            task.spawn(function()
                UI.addLog(Nexus, Decryption, self, method, args, {
                    Caller = caller and caller:GetFullName() or "Unknown",
                    Debug = info
                })
            end)
        end
        
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

-- [ REMOTE BROWSER ]
function Core.getRemotes()
    local remotes = {}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(remotes, v)
        end
    end
    return remotes
end

return Core
