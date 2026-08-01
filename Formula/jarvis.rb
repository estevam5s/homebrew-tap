class Jarvis < Formula
  desc "Assistente de voz que roda local no seu Mac"
  homepage "https://jarvis-micro-saas.vercel.app"
  url "https://wpmohryglkkkgqpxdrjr.supabase.co/storage/v1/object/public/releases/v0.2.1/JARVIS-0.2.1-macos.zip"
  version "0.2.1"
  sha256 "b85e1899b4e2aeaa0c5b429111d4ef2222aa50df017d396495d93102a559b134"
  license :cannot_represent

  depends_on "python@3.12"

  def install
    # Dir["*"] ignora arquivos ocultos, e sem o .env.example o wrapper não tem
    # de onde criar a configuração inicial.
    libexec.install Dir["*"] + Dir[".[^.]*"]

    # O JARVIS roda a partir de ~/.jarvis, não do prefixo do Homebrew, por dois
    # motivos: `brew install` roda numa sandbox sem rede (um `pip install` aqui
    # falharia), e o app grava .env, banco e licença ao lado do próprio código
    # — coisas que não cabem num diretório que o Homebrew substitui a cada
    # atualização. O wrapper sincroniza o código na primeira execução e sempre
    # que a versão muda.
    (bin/"jarvis").write <<~SHELL
      #!/bin/bash
      set -euo pipefail

      ORIGEM="#{libexec}"
      VERSAO="#{version}"
      DADOS="${JARVIS_HOME:-$HOME/.jarvis}"
      APP="$DADOS/app"
      PY="#{Formula["python@3.12"].opt_bin}/python3.12"

      if [ "$(cat "$APP/.versao-brew" 2>/dev/null || echo nada)" != "$VERSAO" ]; then
        echo "  Instalando o JARVIS $VERSAO em $APP..."
        mkdir -p "$APP"
        # --exclude preserva o que é do usuário: chaves, licença e memória.
        rsync -a --delete \\
          --exclude '.env' --exclude 'data' --exclude 'venv' --exclude '.versao-brew' \\
          "$ORIGEM/" "$APP/"
        echo "$VERSAO" > "$APP/.versao-brew"
        rm -rf "$APP/venv"
      fi

      if [ ! -x "$APP/venv/bin/python" ]; then
        echo "  Preparando o ambiente Python (só desta vez)..."
        "$PY" -m venv "$APP/venv"
        "$APP/venv/bin/python" -m pip install --quiet --upgrade pip
        "$APP/venv/bin/python" -m pip install --quiet -r "$APP/requirements.txt"
      fi

      [ -f "$APP/.env" ] || { cp "$APP/.env.example" "$APP/.env"; chmod 600 "$APP/.env"; }

      cd "$APP"
      exec "$APP/venv/bin/python" cli.py "$@"
    SHELL
  end

  def caveats
    <<~EOS
      Antes do primeiro uso:

        jarvis auth --licenca SUA-CHAVE   ativa esta máquina
        jarvis config                     escolhe o provedor de IA e de voz

      Sua chave de licença está em
      https://jarvis-micro-saas.vercel.app/dashboard/licenca

      O JARVIS fica em ~/.jarvis; suas chaves e sua memória continuam lá entre
      atualizações. Calendário, Mail e Notas pedem autorização do macOS no
      primeiro acesso.
    EOS
  end

  test do
    assert_match "assistente de voz", shell_output("#{bin}/jarvis --help")
  end
end
