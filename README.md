# PAYU модуль для NoDeny 49/50

Модуль для биллинговой системы NoDeny реализует протокол взаимодействия с [платежной системой PAYU](http://www.payu.ua).

## Установка

- Скопировать скрипт payu.pl в директорию /usr/local/www/apache22/cgi-bin/payu
- Изменить настройки скрипта payu.pl (MERCHANT, SECRET_KEY)
- При необходимости указать нужную платежную категорию в payu.pl (CATEGORY)
- Обеспечить доступность payu.pl через web только с сети 83.96.157.64/27 (apache, nginx)
- Скопировать Spayu.pl в директорию /usr/local/nodeny/web
- Изменить настройки скрипта Spayu.pl (MERCHANT, SECRET_KEY)
- Изменить STAT_HOST в скрипте Spayu.pl на реальный хост статистики (например, stat.provider.ua)
- Добавить модуль в конфигурацию модулей биллинга (аналогично вложенному plugin_reestr.cfg)
- Исправить скрипт биллинга /usr/local/nodeny/web/paystype.pl аналогично вложенному,
  чтобы корректно отображалась новая платежная категория (можно не делать этого, а использовать одну из
  существующих категорий)
- В административной панели биллинга добавить модуль Spayu
- В клиентской статистике должен появиться новый раздел

## Maintainers and Authors

Yuriy Kolodovskyy (https://github.com/kolodovskyy)

## License

MIT License. Copyright 2013 [Yuriy Kolodovskyy](http://twitter.com/kolodovskyy)
