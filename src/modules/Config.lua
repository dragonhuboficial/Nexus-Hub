local Config = {
    Version = "7.0 Apex (Modular)",
    Active = false,
    Settings = {
        Decryption = true,
        AutoScroll = true,
        BlockRemotes = false,
        MaxLogs = 200,
        Theme = Color3.fromRGB(0, 170, 255)
    },
    Data = {
        Logs = {},
        Remotes = {},
        Blocked = {},
        Stats = { Calls = 0, Decrypted = 0 }
    }
}

return Config
