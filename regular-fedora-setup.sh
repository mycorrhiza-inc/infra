set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

sudo dnf install git fish neovim -y

sudo dnf copr enable atim/lazygit -y
sudo dnf copr enable varlad/zellij -y
sudo dnf install zellij -y
sudo dnf install lazygit -y

sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo systemctl enable --now docker
sudo systemctl start docker

# On macOS and Linux.
curl -LsSf https://astral.sh/uv/install.sh | sudo sh
