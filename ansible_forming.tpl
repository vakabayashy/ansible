all:
        children:
          web:
            hosts:
              ${server_dns}:
        vars:
          ansible_ssh_user: root
