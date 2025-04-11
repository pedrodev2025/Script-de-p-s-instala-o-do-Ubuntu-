#!/bin/bash

# Função para verificar o status do comando e sair em caso de erro
check_status() {
  if [ "$?" -ne 0 ]; then
    echo "ERROR: O comando '$1' falhou com código de saída $?. Saindo do script." | tee -a /var/logs/post-install-ubuntu-logs.log
    exit 1
  fi
}

# Tenta fazer ping em um servidor confiável (Google DNS)
ping -c 1 8.8.8.8 > /dev/null 2>&1
check_status "ping -c 1 8.8.8.8"

if [ "$?" -eq 0 ]; then
  echo "Conectado à internet. Continuando o script..." | tee -a /var/logs/post-install-ubuntu-logs.log
  echo A Instalação Está Começando Por Favor Espere | tee -a /var/logs/post-install-ubuntu-logs.log

  # Criando Pastas De Produtividade
  echo Criando Pastas De Produtividade | tee -a /var/logs/post-install-ubuntu-logs.log
  mkdir /home/$USER/TEMP
  check_status "mkdir /home/$USER/TEMP"
  chmod 700 /home/$USER/TEMP
  check_status "chmod 700 /home/$USER/TEMP"
  mkdir /home/$USER/Documentos/Planilhas
  check_status "mkdir /home/$USER/Documentos/Planilhas"
  chmod 700 /home/$USER/Documentos/Planilhas
  check_status "chmod 700 /home/$USER/Documentos/Planilhas"
  mkdir /home/$USER/AppImages/
  check_status "mkdir /home/$USER/AppImages/"
  chmod 700 /home/$USER/AppImages/
  check_status "chmod 700 /home/$USER/AppImages/"
  sudo apt update -y | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt update -y"
  sudo apt upgrade -y | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt upgrade -y"
  # Remover locks do APT (manter com cautela)
  sudo rm /var/lib/dpkg/lock-frontend
  check_status "sudo rm /var/lib/dpkg/lock-frontend"
  sudo rm /var/cache/apt/archives/lock
  check_status "sudo rm /var/cache/apt/archives/lock"
  sudo apt install curl -y | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt install curl -y"
  sudo apt install wget -y | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt install wget -y"
  sudo apt install unzip -y | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt install unzip -y"
  echo Instalando Flatpak | tee -a /var/logs/post-install-ubuntu-logs.log
  sudo apt install flatpak -y | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt install flatpak -y"
  echo Instalando Chrome | tee -a /var/logs/post-install-ubuntu-logs.log
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  check_status "wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  sudo apt install -y ./google-chrome-stable_current_amd64.deb | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt install -y ./google-chrome-stable_current_amd64.deb"
  echo Instalando Flathub | tee -a /var/logs/post-install-ubuntu-logs.log
  flatpak remote-add  --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "flatpak remote-add  --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
  echo Instalando VLC | tee -a /var/logs/post-install-ubuntu-logs.log
  flatpak install -y flathub org.videolan.VLC | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "flatpak install -y flathub org.videolan.VLC"
  echo Instalando gimp | tee -a /var/logs/post-install-ubuntu-logs.log
  flatpak install -y flathub org.gimp.GIMP | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "flatpak install -y flathub org.gimp.GIMP"
  echo Instalando Audacity | tee -a /var/logs/post-install-ubuntu-logs.log
  flatpak install -y flathub org.audacityteam.Audacity | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "flatpak install -y flathub org.audacityteam.Audacity"
   echo Instalando Onlyoffice | tee -a /var/logs/post-install-ubuntu-logs.log
   flatpak install flathub org.onlyoffice.desktopeditors | tee -a /var/logs/post-install-ubuntu-logs.log
   check_status "flatpak install flathub org.onlyoffice.desktopeditors"
   echo Instalando LM Studio | tee -a /var/logs/post-install-ubuntu-logs.log
   wget -O /home/$USER/AppImages/lmstudio.AppImage https://installers.lmstudio.ai/linux/x64/0.3.14-5/LM-Studio-0.3.14-5-x64.AppImage
   check_status "wget -O /home/$USER/AppImages/lmstudio.AppImage https://installers.lmstudio.ai/linux/x64/0.3.14-5/LM-Studio-0.3.14-5-x64.AppImage"
   echo Instalando Gnome Software | tee -a /var/logs/post-install-ubuntu-logs.log
   sudo apt install gnome-software -y | tee -a /var/logs/post-install-ubuntu-logs.log
   check_status "sudo apt install gnome-software -y"
   sudo apt install gnome-software-plugin-flatpak -y | tee -a /var/logs/post-install-ubuntu-logs.log
   check_status "sudo apt install gnome-software-plugin-flatpak -y"
  # Removendo Programas
  echo Removendo Programas | tee -a /var/logs/post-install-ubuntu-logs.log
  # Removendo Snap
  echo Removendo Snap | tee -a /var/logs/post-install-ubuntu-logs.log
  SNAP_PACKAGES=$(snap list | awk 'NR>1 {print $1}')
  if [ -n "$SNAP_PACKAGES" ]; then
    echo "Removendo os seguintes snaps: $SNAP_PACKAGES" | tee -a /var/logs/post-install-ubuntu-logs.log
    sudo snap remove -y --purge $SNAP_PACKAGES
    check_status "sudo snap remove -y --purge $SNAP_PACKAGES"
  fi
  echo "Removendo o snapd" | tee -a /var/logs/post-install-ubuntu-logs.log
  sudo apt purge snapd -y | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt purge snapd -y"
  # Removendo Libreoffice
  echo Removendo Libreoffice | tee -a /var/logs/post-install-ubuntu-logs.log
  sudo apt purge libreoffice* -y | tee -a /var/logs/post-install-ubuntu-logs.log
  check_status "sudo apt purge libreoffice* -y"
  echo "Script concluído." | tee -a /var/logs/post-install-ubuntu-logs.log
  exit 0

else
  echo "ERROR: Esse Script Precisa De Internet. Por Favor Conecte A Internet." | tee -a /var/logs/post-install-ubuntu-logs.log
  exit 1
fi
