Vagrant.configure("2") do |config|
	config.vm.define "stepca" do |host|
		host.vm.box = "ubuntu/bionic64"
		host.vm.hostname = "stepca"
        config.ssh.insert_key = false
        config.vm.provision "shell", inline: <<-SHELL
            sudo apt-get update
            sudo apt-get install -y wget openssh-server iputils-ping
            wget https://dl.smallstep.com/cli/docs-ca-install/latest/step-cli_amd64.deb
            wget https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb
            sudo dpkg -i step-cli_amd64.deb
            sudo dpkg -i step-ca_amd64.deb

            # STEP
            echo password > /root/password.txt
            step ca init --ssh \
                         --deployment-type standalone \
                         --name step-ca-example \
                         --dns stepca \
                         --address :8443 \
                         --provisioner step-ca@example.com \
                         --password-file /root/password.txt
            step ssh certificate stepca /etc/ssh/ssh_host_ecdsa_key.pub \
                         --offline \
                         --sign \
                         --host \
                         --password-file /root/password.txt \
                         --provisioner step-ca@example.com

            # CREATE USER
            sudo adduser --quiet --disabled-password --gecos '' testuser 2>/dev/null

            # SSH 
            echo 'TrustedUserCAKeys /root/.step/certs/ssh_user_ca_key.pub' >> /etc/ssh/sshd_config && \
            echo 'HostCertificate /etc/ssh/ssh_host_ecdsa_key-cert.pub' >> /etc/ssh/sshd_config
            # echo 'HostKey /keys/ssh_host_ecdsa_key' >> /etc/ssh/sshd_config
            service ssh restart

            # ECHO root/.step/certs/ssh_host_ca_key.pub
            echo 'Add following line to your local hosts ~/.ssh/known_hosts file to accept host certs' && \
            echo "@cert-authority * $(cat /root/.step/certs/ssh_host_ca_key.pub | tr -d '\n')"
            
            # STEP CA SYSTEMCTL
            mkdir -p /root/.scripts /root/logs
            echo -e '#!/usr/bin/env bash\nstep-ca /root/.step/config/ca.json --password-file /root/password.txt 1>> /root/logs/step-ca.out 2>> /root/logs/step-ca.err\n' > /root/.scripts/step-ca.sh
            echo -e '[Unit]\nDescription=Start step ca\nAfter=multi-user.target\n\n[Service]\nExecStart=/usr/bin/env bash /root/.scripts/step-ca.sh\nType=simple\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/step-ca.service
            sudo systemctl daemon-reload
            sudo systemctl enable step-ca.service --now
            sudo systemctl status step-ca.service
            
            sudo ufw allow 8443
            sudo ufw status verbose
            
            cat /root/logs/step-ca.*
        SHELL
        config.vm.provision "shell", run: "always", inline: "systemctl start step-ca.service"
        host.vm.network "private_network", ip: "192.168.56.10"
        config.vm.network "forwarded_port", guest: 8443, host: 8443
        # host.vm.synced_folder "keys", "/keys"
    end
end


