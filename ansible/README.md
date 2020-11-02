# Ansible

### Настройка
1. В файле `.vault_pass` лежит пароль от ansible vault.
1. Для корректной работы ansible лучше использовать virtualenv:
    ```shell script
    virtualenv -p /usr/local/bin/python3 ~/.local
    . ~/.local/bin/activate
    ```
1. Установить необходимые зависимости:
    ```shell script
    pip install -r requirements.txt
    ```
   
### Запуск playbook
```shell script
ansible-playbook -i inventories/local/static.yml --vault-password-file=.vault_pass kubernetes.yml
```

### Пояснения
Т.к. `VirtualBox` по-умолчанию создает интерфейс enp0s3 с адресом`10.0.2.15` и назначение дефолтные маршруты
через него,  то в конфигурации flannel (для запуска `flanneld`) нужно явно прописать какой интерфейс использовать `--iface=enp0s8`.