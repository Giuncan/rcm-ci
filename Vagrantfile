Vagrant.configure("2") do |config|
	config.vm.define "testhost" do |host|
		host.vm.box = "ubuntu/bionic64"
		host.vm.hostname = "testhost"
        config.vm.provision "shell", inline: <<-SHELL
            sudo apt-get update
            sudo apt-get install -y wget openssh-server iputils-ping supervisor
            wget https://dl.smallstep.com/cli/docs-ca-install/latest/step-cli_amd64.deb
            wget https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb
            sudo dpkg -i step-cli_amd64.deb
            sudo dpkg -i step-ca_amd64.deb

            # STEP
            echo password > password.txt
            step ca init --ssh \
                         --deployment-type standalone \
                         --name step-ca-example \
                         --dns testhost \
                         --address :8443 \
                         --provisioner step-ca@example.com \
                         --password-file password.txt
            step ssh certificate testhost /etc/ssh/ssh_host_ecdsa_key.pub \
                         --offline \
                         --sign \
                         --host \
                         --password-file password.txt \
                         --provisioner step-ca@example.com

            # SSH
            sudo adduser --quiet --disabled-password --gecos '' testuser 2>/dev/null
            echo 'TrustedUserCAKeys /root/.step/certs/ssh_user_ca_key.pub' >> /etc/ssh/sshd_config && \
            echo 'HostCertificate /etc/ssh/ssh_host_ecdsa_key-cert.pub' >> /etc/ssh/sshd_config
            # echo 'HostKey /keys/ssh_host_ecdsa_key' >> /etc/ssh/sshd_config
            service ssh restart
            echo "#!/usr/bin/env bash\nstep-ca /root/.step/config/ca.json --password-file password.txt 1>> /root/logs/step-ca.out 2>> /root/logs/step-ca.err\n" > /root/.scripts/step-ca.sh
            echo "[Unit]\nDescription=Start step ca\nAfter=multi-user.target\n\n[Service]\nExecStart=/usr/bin/bash /root/.scripts/step-ca.sh\nType=simple\n\n[Install]\nWantedBy=multi-user.target\n" > /etc/systemd/system/step-ca.service
            sudo systemctl daemon-reload
            sudo systemctl enable step-ca.service                        
        SHELL
		host.vm.network "private_network", ip: "192.168.1.51"
        # host.vm.synced_folder "keys", "/keys"
    end
end

