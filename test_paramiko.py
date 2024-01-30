import paramiko
import logging
import sys

logging.basicConfig()
logging.getLogger("paramiko").setLevel(logging.DEBUG)


def connect(host, user, port=22, password=None, allow_agent=True):
    # print("{0}\n{1}\n{0}".format("#"*80, cluster))

    print("#1 initializing")
    ssh = paramiko.SSHClient()

    # Automatically load host if unknown
    # https://stackoverflow.com/questions/52632693/force-password-authentication-ignore-keys-in-ssh-folder-in-paramiko-in-python
    print("#2 missing host key policy")
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    print("#3 connect")
    ssh.connect(
        host,
        username=user,
        password=password,
        port=port,
        allow_agent=allow_agent,
        timeout=10,
        )

    print("#4 get auth_method")
    print(ssh.get_transport().auth_handler.auth_method)


if __name__ == "__main__":
    args = sys.argv
    for key in paramiko.agent.Agent().get_keys():
        if not hasattr(key, "public_blob"):
            key.public_blob = None
        print(key.public_blob)

    connect(host=args[1],
            user=args[2],
            port=int(args[3]),
            password=None if args[4] == "None" else args[4],
            allow_agent=False if args[5] == "False" else True,
            )
