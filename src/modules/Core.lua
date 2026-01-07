local Core = {}

function Core.hook(Nexus, UI, Decryption)
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if _G.NexusActive and (method == "FireServer" or method == "InvokeServer") then
            task.spawn(function()
                UI.addLog(Nexus, Decryption, self, method, args)
            end)
        end
        
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

return Core
