local Core = {}

-- [ UTILITÁRIOS DE INSPEÇÃO ]
local function getFunctionUpvalues(f)
    if not debug or not debug.getupvalues then return {} end
    local upvalues = {}
    local success, res = pcall(debug.getupvalues, f)
    if success then
        for i, v in pairs(res) do
            upvalues[i] = v
        end
    end
    return upvalues
end

function Core.hook(Nexus, UI, Decryption)
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    setreadonly(mt, false)

    -- [ HOOK: NAMECALL ]
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if _G.NexusActive and (method == "FireServer" or method == "InvokeServer") then
            -- Deep Inspection: Tentar capturar o script chamador e upvalues
            local caller = getcallingscript and getcallingscript() or "Unknown"
            local upvalues = {}
            
            -- Tenta inspecionar a função que chamou o remote (se possível)
            pcall(function()
                local info = debug.getinfo(2)
                if info and info.func then
                    upvalues = getFunctionUpvalues(info.func)
                end
            end)

            task.spawn(function()
                UI.addLog(Nexus, Decryption, self, method, args, {
                    Caller = tostring(caller),
                    Upvalues = upvalues
                })
            end)
        end
        
        return oldNamecall(self, ...)
    end)

    -- [ HOOK: INDEX (Para capturar propriedades de Remotes) ]
    mt.__index = newcclosure(function(self, key)
        if _G.NexusActive and typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
            -- Opcional: Logar acessos a propriedades sensíveis se necessário
        end
        return oldIndex(self, key)
    end)

    setreadonly(mt, true)
end

return Core
