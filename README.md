Проект раскатывает с помощью andible на Gitlab nginx на виртуальных машинах. 

Выполнить перед стартом пайплайна в гитлаб: поднять VM для dev, prod, vault заполнить переменные в gitlab.
   Этап 1. Поднятие виртуальных машин в YC
   Выполнить скрипт из корня проекта: . ./script-for-VMs.sh
   Этап 2. Заполнение переменных GitLab
   DEPLOY_DEV_HOST - IP виртуалки DEV
   DEPLOY_PROD_HOST - IP виртуалки PROD
   DEPLOY_USER - ubuntu

Сначала устанавливается ANSIBLE GALAXY, затем ANSIBLE PLAYBOOK

Пароль зашифрован с помощью ANSIBLE VAULT, расшифровывается с помощью переменной ANSIBLE_VAULT_PASSWORD
[secrets.yml](ansible/inventory/group_vars/all/secrets.yml)

для автоматической установки докера используется geerlingguy.docker роль.
для перемещения пользователя в группу докера используется переменная docker_users роли выше.