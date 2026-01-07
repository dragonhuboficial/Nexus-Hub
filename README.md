# 📊 Nexus-Hub v7.0 Apex

O **Nexus-Hub** é um sistema modular de extração e análise de dados para Roblox, focado em interceptação de `RemoteEvents` e `RemoteFunctions`.

## 🚀 Como Executar

Para carregar a versão mais recente do Nexus-Hub, utilize o seguinte script no seu executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/dragonhuboficial/Nexus-Hub/main/init.lua"))()
```

## 🏗️ Estrutura Modular

O projeto é dividido em módulos para garantir performance e facilidade de manutenção:

- **init.lua**: Loader principal que gerencia as dependências.
- **Config.lua**: Definições de configurações e estado global.
- **Core.lua**: Lógica de hooking de baixo nível (`__namecall`).
- **Decryption.lua**: Algoritmos de descriptografia e tratamento de strings.
- **UI.lua**: Interface gráfica moderna e responsiva.

## 🛠️ Funcionalidades

- **Hooking Assíncrono**: Captura de dados sem impacto no FPS.
- **Decodificação Inteligente**: Suporte para JSON, Base64 e XOR.
- **Exportação**: Sistema de exportação de logs para JSON via clipboard.

---
*Desenvolvido por Manus para a comunidade Nexus-Hub.*