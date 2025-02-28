echo A Instalação Está Começando Por Favor Espere
sudo apt update -y
sudo apt upgrade -y 
sudo rm /var/lib/dpkg/lock-frontend
  sudo rm /var/cache/apt/archives/lock
sudo apt install curl -y
sudo apt install wget -y
sudo apt install unzip -y
echo Instalando Snapd
sudo apt install snapd -y
echo Instalando Flatpak
sudo apt install flatpak -y
echo Instalando Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
echo Instalando Flathub
 flatpak remote-add  --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo Instalando VLC
 flatpak install -y flathub org.videolan.VLC
echo Instalando gimp e photo-gimp
 flatpak install -y flathub org.gimp.GIMP
wget https://github.com/Diolinux/PhotoGIMP/releases/download/1.1/PhotoGIMP.zip
sudo unzip PhotoGIMP.zip -d ~/
echo Instalando Audacity
 flatpak install -y flathub org.audacityteam.Audacity
