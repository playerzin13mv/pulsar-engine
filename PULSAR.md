# Pulsar Engine 🌌

Engine de FNF para **celular e PC**, feita para rodar mods de **Psych Engine** e **V-Slice**, com criação de mods mais fácil.

Este é o kit inicial. Ele ainda **não contém o código da engine**: o `pulsar-setup.sh` baixa uma base (fork do Psych Engine com suporte a Android), aplica o branding Pulsar e prepara o build automático do APK.

## O que tem no kit

- `pulsar-setup.sh`: baixa a base, renomeia para Pulsar e prepara o repositório.
- `.github/workflows/pulsar-build.yml`: gera o APK (Android) e os builds de Windows e Linux no GitHub Actions.
- `tools/new-mod.sh`: cria a estrutura de um mod novo, pelo Termux ou pelo PC.

## Como usar

1. Rode `bash pulsar-setup.sh`. A base padrão é o fork `melodiekit/PsychEngine-Mobile` (Psych 1.0.4 com Android). Para usar outra: `BASE_REPO=https://github.com/USUARIO/REPO bash pulsar-setup.sh`
2. Crie um repositório vazio no GitHub e envie o código (o script mostra os comandos no final).
3. Abra a aba **Actions** do repositório e baixe o APK gerado em *Artifacts*.

## Criar um mod

`bash tools/new-mod.sh "Nome do Mod"`

Para criar direto na pasta de mods do app no celular, passe o caminho como segundo argumento.

## Importante

- O workflow **não foi testado ainda**. As versões de Haxe, Java, SDK e NDK no topo do arquivo são um ponto de partida e podem precisar de ajuste conforme a base escolhida. O primeiro build costuma pedir correções.
- A base é um projeto de terceiros (Psych Engine, licença Apache 2.0). Mantenha o arquivo de licença e os créditos originais no repositório.
- Se a base já tiver workflows próprios em `.github/workflows`, apague os antigos.

## Roadmap

1. Build do APK funcionando com Psych Engine.
2. Camada de compatibilidade com V-Slice: charts em JSON, scripts HScript e estrutura de mods.
3. Facilitar a criação de mods: criador de mods dentro da engine, mais ferramentas e documentação em português.
