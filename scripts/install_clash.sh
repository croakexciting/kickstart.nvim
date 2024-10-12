#!/bin/bash

function install_clash() {
	echo "install and setup clash"
	if [ ! -d "${HOME}/Downloads/clash" ]; then
		pushd ${HOME}/Downloads
		curl https://glados.rocks/tools/clash-linux.zip -o clash.zip
		unzip clash.zip
		chmod +x clash/clash-linux-amd64*

		# add systemd service
		sudo rm -f /etc/systemd/system/clash.service
		sudo tee /etc/systemd/system/clash.service <<EOF
[Unit]
Description=Clash
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/croak/Downloads/clash
ExecStart=bash -c "cd /home/croak/Downloads/clash; ./clash-linux-amd64-v1.10.0 -f glados.yaml -d ."
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
		sudo systemctl daemon-reload
		sudo systemctl enable clash
		sudo systemctl start clash

		# add http_proxy env into bashrc
		echo 'export http_proxy="http://127.0.0.1:7890"' >> ${HOME}/.bashrc
		echo 'export https_proxy="http://127.0.0.1:7890"' >> ${HOME}/.bashrc
		echo 'export no_proxy="localhost,172.20.*,*landmark*"' >> ${HOME}/.bashrc
		popd
	fi
}

install_clash "$@"
