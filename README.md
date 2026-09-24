Проект раскатывает с помощью andible на Gitlab nginx на виртуальных машинах. 

Выполнить перед стартом пайплайна в гитлаб: поднять VM для dev, prod, vault заполнить переменные в gitlab.
   Этап 1. Поднятие виртуальных машин в YC
   Выполнить скрипт из корня проекта: . ./script-for-VMs.sh
   Этап 2. Заполнение переменных GitLab
   DEPLOY_DEV_HOST - IP виртуалки DEV
   DEPLOY_PROD_HOST - IP виртуалки PROD
   DEPLOY_USER - ubuntu
   DEPLOY_PASSWD - otus