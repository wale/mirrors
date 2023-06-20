# Mirrors
This is the backing infrastructure code for the **[mirrors.wale.id.au](https://mirrors.wale.id.au)** Linux mirror. The server is hosted in Sydney, Australia.

## How to use
This mirror expects _Alpine Linux_ to be installed on the system, as well as using Cloudflare for DNS.

Replace the `ansible-vault`-generated Cloudflare API token in `caddy/tasks/main.yml` with your own password-protected token, where the password is stored in `.ansible_password`.

Then run the Ansible playbook with your vault, like so:
```
ansible-playbook -i hosts site.yml --vault-id ssh_port@.ansible_password
```