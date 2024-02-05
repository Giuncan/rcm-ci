# syntax=docker/dockerfile:1

# sudo docker build -t step-ca  --no-cache --progress=plain . 2>&1 | tee build.log
# sudo docker network create --subnet=172.18.0.0/16 mynet123
# sudo docker run --hostname testhost  --net mynet123 --ip 172.18.0.22 -p 2222:22 step-ca

# step ca bootstrap --fingerprint 622fb8bcae95def5637ddf02d694f8ef507b4d5caffe3eadca39cae0dd01f967 --ca-url=https://stepca:8443
# step ssh login testuser


FROM ubuntu:22.04
# WORKDIR /app
# COPY . .
RUN \
    apt-get update && \
    apt-get install -y wget openssh-server iputils-ping supervisor && \
    wget https://dl.smallstep.com/cli/docs-ca-install/latest/step-cli_amd64.deb  && \
    wget https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_amd64.deb && \
    dpkg -i step-cli_amd64.deb && \
    dpkg -i step-ca_amd64.deb
RUN \
    echo password > password.txt && \
    step ca init --ssh \
                 --deployment-type standalone \
                 --name step-ca-example \
                 --dns stepca \
                 --address :8443 \
                 --provisioner step-ca@example.com \
                 --password-file password.txt && \
    step ssh certificate stepca /etc/ssh/ssh_host_ecdsa_key.pub \
                 --offline \
                 --sign \
                 --host \
                 --password-file password.txt \
                 --provisioner step-ca@example.com
RUN adduser --quiet --disabled-password --gecos '' testuser 2>/dev/null && \
    echo 'TrustedUserCAKeys /root/.step/certs/ssh_user_ca_key.pub' >> /etc/ssh/sshd_config && \
    echo 'HostCertificate /etc/ssh/ssh_host_ecdsa_key-cert.pub' >> /etc/ssh/sshd_config
    # echo 'HostKey /keys/ssh_host_ecdsa_key' >> /etc/ssh/sshd_config && \
RUN mkdir /var/run/sshd
RUN echo "[supervisord]\nnodaemon=true\nuser=root\n\n[program:sshd]\ncommand=/usr/sbin/sshd -D\n\n[program:step-ca]\ncommand=step-ca /root/.step/config/ca.json --password-file password.txt\n" > /etc/supervisor/conf.d/supervisord.conf
# CMD ["sh", "/root/cmd.sh"]
CMD ["/usr/bin/supervisord"]
# CMD ["/usr/sbin/sshd", "-D"] 
# CMD ["step-ca", "/root/.step/config/ca.json", "--password-file", "password.txt"]
EXPOSE 8443
EXPOSE 22
