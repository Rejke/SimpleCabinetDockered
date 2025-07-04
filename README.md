# SimpleCabinetDockered

Этот набор скриптов предоставляет возможность быстрого запуска SimpleCabinet вместе с GravitLauncher без необходимости ручной настройки. Дополнительную информацию по работе с Docker и лаунчером в нем можно получить [здесь](https://github.com/GravitLauncher/LauncherDockered)

Этот образ основан на [LauncherDockered](https://github.com/GravitLauncher/LauncherDockered) и все команды по управлению лаунчером так же применимы к SimpleCabinetDocker

# Требования

Поскольку скрипт выполняет много действий на локальной машине, на ней должны быть установлены:

- Git
- OpenSSL
- Sed
- Docker
- Jq

Рекомендуется иметь не менее 2Гб оперативной памяти для сборки и работы

# Установка

- Откройте setup.sh и настройте параметр SIMPLECABINET_REMOTE: он должен содержать тот адрес по которому ваш SimpleCabinet и лаунчер будут доступны извне. Если у вас есть домен и настроен https - поменяйте SIMPLECABINET_PROTOCOL на https
- Так же перед установкой можно поменять порт на котором будет доступен лаунчер и кабинет(по умолчанию 17549). Сделать это можно в docker-compose.yml в разделе nginx -> ports
- Установите всё необходимое если у вас еще его нет(см раздел Требования)
- Запустите скрипт установки `./setup.sh`
- После окончания работы скрипта установки кабинет будет полностью готов к работе

# Ограничения

- Если вы указали https, из за ограничений автоустановки в LaunchServer.json будет использоватся http и ws. Измените эти параметры вручную после завершения установки
- Не будет работать загрузка скинов и плащей из лаунчера(при этом с сайта будет работать корректно) из за того что модуль отправляет клиенту адрес внутри docker сети, а не внешний. Вручную укажите правильный внешний адрес в конфигурации авторизации

# Полезное

- Адрес для скачивания лаунчера: SIMPLECABINET_REMOTE/launcher/Launcher.jar ( по умолчанию http://localhost:17549/launcher/Launcher.jar )
- Как выдать себе админку:
  - Зарегистрируйтесь обычным способом
  - Выйдите из аккаунта
  - Войдите под аккаунтом администратора(логин admin, пароль в setup.json в корне установки)
  - Найдите в разделе "Пользователи" себя. Нажмите на значек "плюс" возле "Группы" и добавьте себе группу ADMIN
  - Выйдите из аккаунта администратора и вновь зайдите в свой аккаунт.
