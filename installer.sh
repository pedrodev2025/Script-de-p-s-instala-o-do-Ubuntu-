#!/bin/bash

# Variável para o arquivo de log
LOG_FILE="/var/log/post-install-ubuntu-logs.log"

# Função para exibir mensagens e registrar no log
log_message() {
  echo "$1" | tee -a "$LOG_FILE"
}

# Função para verificar o status do comando e sair em caso de erro
check_status() {
  local cmd_name="$1" # Corrigido: Agora usa o primeiro argumento como nome do comando
  if [ "$?" -ne 0 ]; then
    log_message "ERROR: O comando '$cmd_name' falhou com código de saída $?. Saindo do script."
    exit 1
  fi
}

# Verifica se o script está sendo executado com sudo
if [[ $EUID -ne 0 ]]; then
  log_message "ERROR: Este script precisa ser executado com privilégios de root (sudo)."
  exit 1
fi

# Tenta fazer ping em um servidor confiável (Google DNS)
log_message "Verificando conexão com a internet..."
ping -c 1 8.8.8.8 > /dev/null 2>&1
check_status "ping -c 1 8.8.8.8"

# Se chegamos aqui, a conexão está ok
# Define a variável USER para o usuário que chamou o sudo
USER=$SUDO_USER
if [ -z "$USER" ]; then
  log_message "ERROR: Não foi possível determinar o usuário que invocou o sudo. Saindo."
  exit 1
fi
groupadd $USER
log_message "Conectado à internet. Continuando o script..."
log_message "A Instalação Está Começando. Por favor, espere..."

# Criando Pastas De Produtividade
log_message "Criando Pastas De Produtividade"

# Configurando a pasta TEMP como tmpfs
log_message "Configurando a pasta /home/$USER/TEMP como tmpfs..."
mkdir -p "/home/$USER/TEMP"
check_status "mkdir -p /home/$USER/TEMP"
chown "$USER":"$USER" "/home/$USER/TEMP" # Adicionado chown
chmod 700 "/home/$USER/TEMP"
check_status "chmod 700 /home/$USER/TEMP"

# Adiciona a entrada tmpfs ao /etc/fstab
# Recomenda-se um tamanho máximo para evitar o uso excessivo de RAM.
# Ex: size=2G para 2GB, ou 50% da RAM (size=50%)
# Pode ajustar o 'size' conforme a necessidade do usuário.
FSTAB_ENTRY="tmpfs /home/$USER/TEMP tmpfs rw,nosuid,nodev,noatime,size=4G,uid=$USER,gid=$USER,mode=700 0 0"

# Verifica se a entrada já existe para evitar duplicações
if ! grep -q "^tmpfs /home/$USER/TEMP" /etc/fstab; then
  log_message "Adicionando entrada para tmpfs em /etc/fstab..."
  echo "$FSTAB_ENTRY" >> /etc/fstab
  check_status "adicionar tmpfs ao /etc/fstab"
  log_message "Entrada para tmpfs adicionada ao /etc/fstab."
else
  log_message "Entrada para tmpfs já existe em /etc/fstab. Pulando adição."
fi

# Monta o tmpfs imediatamente
log_message "Montando o tmpfs para /home/$USER/TEMP..."
mount "/home/$USER/TEMP"
check_status "mount /home/$USER/TEMP"
log_message "Pasta /home/$USER/TEMP agora é um tmpfs."

mkdir -p "/home/$USER/Documentos/Planilhas"
check_status "mkdir -p /home/$USER/Documentos/Planilhas"
chown "$USER":"$USER" "/home/$USER/Documentos/Planilhas" # Adicionado chown
chmod 700 "/home/$USER/Documentos/Planilhas"
check_status "chmod 700 /home/$USER/Documentos/Planilhas"

mkdir -p "/home/$USER/AppImages/"
check_status "mkdir -p /home/$USER/AppImages/"
chown "$USER":"$USER" "/home/$USER/AppImages/" # Adicionado chown
chmod 700 "/home/$USER/AppImages/"
check_status "chmod 700 /home/$USER/AppImages/"

log_message "Atualizando e atualizando o sistema..."
apt update -y
check_status "apt update -y"
apt upgrade -y
check_status "apt upgrade -y"

log_message "Instalando utilitários básicos (curl, wget, unzip)..."
apt install curl -y
check_status "apt install curl -y"
apt install wget -y
check_status "apt install wget -y"
apt install unzip -y
check_status "apt install unzip -y"

log_message "Instalando Flatpak..."
apt install flatpak -y
check_status "apt install flatpak -y"

log_message "Instalando Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O "/home/$USER/google-chrome-stable_current_amd64.deb"
check_status "wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
apt install -y "/home/$USER/google-chrome-stable_current_amd64.deb"
check_status "apt install -y /home/$USER/google-chrome-stable_current_amd64.deb"
rm "/home/$USER/google-chrome-stable_current_amd64.deb"
log_message "Google Chrome instalado e arquivo .deb removido."

log_message "Adicionando o repositório Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_status "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"

log_message "Atualizando o banco de dados do Flatpak..."
flatpak update --noninteractive
check_status "flatpak update --noninteractive"

# Instalação de aplicativos Flatpak
log_message "Instalando VLC (via Flatpak)..."
flatpak install --noninteractive flathub org.videolan.VLC
check_status "flatpak install --noninteractive flathub org.videolan.VLC"

log_message "Instalando GIMP (via Flatpak)..."
flatpak install --noninteractive flathub org.gimp.GIMP
check_status "flatpak install --noninteractive flathub org.gimp.GIMP"

log_message "Instalando Audacity (via Flatpak)..."
flatpak install --noninteractive flathub org.audacityteam.Audacity
check_status "flatpak install --noninteractive flathub org.audacityteam.Audacity"

log_message "Instalando Onlyoffice (via Flatpak)..."
flatpak install --noninteractive flathub org.onlyoffice.desktopeditors
check_status "flatpak install --noninteractive flathub org.onlyoffice.desktopeditors"

log_message "Instalando LM Studio..."
# Removida a verificação redundante por 'wget', já que ele é instalado no início do script.
LM_STUDIO_URL="https://installers.lmstudio.ai/linux/x64/0.3.14-5/LM-Studio-0.3.14-5-x64.AppImage"
OUTPUT_PATH="/home/$USER/AppImages/lmstudio.AppImage"
log_message "Baixando LM Studio de: $LM_STUDIO_URL para $OUTPUT_PATH"
wget -O "$OUTPUT_PATH" "$LM_STUDIO_URL"
check_status "wget -O \"$OUTPUT_PATH\" \"$LM_STUDIO_URL\"" # Corrigido: Usando a variável correta
chmod +x "$OUTPUT_PATH"
check_status "chmod +x \"$OUTPUT_PATH\"" # Corrigido: Sintaxe da string

log_message "Instalando Gnome Software e plugin Flatpak..."
apt install gnome-software -y
check_status "apt install gnome-software -y"
apt install gnome-software-plugin-flatpak -y
check_status "apt install gnome-software-plugin-flatpak -y"

# Removendo Programas
log_message "Removendo Programas..."
# Removendo Snap
log_message "Removendo Snap..."
# Obtém uma lista de pacotes snap instalados, excluindo a primeira linha (cabeçalho)
SNAP_PACKAGES=$(snap list | awk 'NR>1 {print $1}')
if [ -n "$SNAP_PACKAGES" ]; then
  log_message "Removendo os seguintes snaps: $SNAP_PACKAGES"
  for snap_package in $SNAP_PACKAGES; do
    log_message "Tentando remover snap: $snap_package"
    snap remove "$snap_package" --purge --no-wait
    # O check_status pode não funcionar bem aqui se 'snap remove' retornar 0 mesmo com avisos.
    # Para scripts de autoinstalação, se a intenção é apenas tentar remover, pode-se confiar
    # na saída do comando sem interromper o script.
    # check_status "snap remove $snap_package --purge --no-wait"
  done
  log_message "Remoção de snaps concluída."
else
  log_message "Nenhum snap encontrado para remover."
fi

log_message "Script de pós-instalação concluído com sucesso!"
