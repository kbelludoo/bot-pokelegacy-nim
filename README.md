# PokeLegacy Online Native Nim Bot (Zero-GC & Ultra-Light)

Bot autônomo multi-contas de alta performance para o jogo **PokeLegacy Online**, reescrito em **Nim 2.2** com gerenciamento de memória ORC (`--mm:orc`), consumo ultra-baixo de RAM (< 10MB) e 100% de paridade com as versões em Go e Rust.

## Funcionalidades
- **Gestão Multi-Contas**: Execução assíncrona de todas as contas configuradas em `accounts.json`.
- **Autenticação e Sessão**: Validação via `/api/me` e `/api/login` com cabeçalhos e device UUID nativos.
- **Ciclo de Caça Contínuo**: Simulação e envio de abates e coleta periódica.
- **Furtividade Anti-Detecção**: Jitter orgânico contínuo em todos os loops e pausas de pacing humano.
- **Dashboard e API HTTP**: Endpoint `/api/status` na porta 3005 com métricas em tempo real.

## Compilação

### Linux (Cross-compilação com Zig):
```bash
nim c --os:linux --cpu:amd64 --gcc.exe:zigcc-linux-gnu.bat --gcc.linkerexe:zigcc-linux-gnu.bat -d:ssl -d:release -o:bot-pokelegacy-linux-nim main.nim
```

### Windows:
```bash
nim c -d:ssl -d:release -o:bot-pokelegacy-nim.exe main.nim
```
