#!/usr/bin/env bash
# Pulsar Engine - criador de mods
# Cria a estrutura de pastas de um mod novo, no celular (Termux) ou no PC.
#
# Uso:
#   bash tools/new-mod.sh "Nome do Mod" [pasta-de-mods]
#
# Exemplos:
#   bash tools/new-mod.sh "Meu Primeiro Mod"
#   bash tools/new-mod.sh "Meu Mod" /sdcard/Android/data/com.pulsar.engine/files/mods
#
# Dica: no Termux, rode "termux-setup-storage" uma vez para acessar o armazenamento.

set -euo pipefail

NAME="${1:-}"
MODS_DIR="${2:-mods}"

if [ -z "$NAME" ]; then
  echo "Uso: bash tools/new-mod.sh \"Nome do Mod\" [pasta-de-mods]"
  exit 1
fi

SLUG="$(echo "$NAME" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9_-')"
if [ -z "$SLUG" ]; then
  echo "Erro: use pelo menos uma letra ou número no nome do mod."
  exit 1
fi

TARGET="$MODS_DIR/$SLUG"
if [ -e "$TARGET" ]; then
  echo "Erro: '$TARGET' já existe."
  exit 1
fi

mkdir -p "$TARGET"/{characters,custom_events,custom_notetypes,data,images,music,scripts,shaders,songs,sounds,stages,videos,weeks}

cat > "$TARGET/pack.json" <<EOF
{
  "name": "$NAME",
  "description": "Mod criado com a Pulsar Engine.",
  "restart": false,
  "runsGlobally": false,
  "color": [170, 0, 255]
}
EOF

cat > "$TARGET/LEIAME.txt" <<'EOF'
Estrutura do mod:
  characters/        personagens (.json)
  custom_events/     eventos personalizados do chart editor
  custom_notetypes/  tipos de nota personalizados
  data/              charts, dialogos e scripts por música (data/NOME_DA_MUSICA/)
  images/            sprites e atlas
  music/ songs/      músicas do menu e músicas das fases (Inst/Voices)
  scripts/           scripts globais (.lua / .hx)
  shaders/           shaders
  stages/            cenários (.json)
  weeks/             semanas (.json)
  pack.json          nome, descrição e cor do mod
EOF

echo "Mod criado em: $TARGET"
