# consolication

> Консоль для общения с сервером с использованием WebSocket.

## Зависимости

> [React](http://facebook.github.io/react/) ~0.4

## Сборка минифицированной версии

```bash
git clone git@github.com:rithis/consolication.git
cd consolication
npm install -g grunt-cli
npm install
grunt build
```

## Использование

Для инициализации консоли на странице достаточно подключить `consolication.css`
и `consolication.js` и вставить на страницу элемент
с идентификатором `consolication`. Пример:

```html
<link rel="stylesheet" src="consolication.css"/>
<script src="consolication.js"></script>
<div id="consolication"></div>
```

Конфигурировать консоль можно с помощью добавления аттрибутов к элементу.
Доступные аттрибуты:

* `data-autofocus` — сразу сфокусироваться на поле ввода при загрузке страницы.
* `data-ws-server` — жестко определить адрес к WebSocket серверу.
* `data-terminal-emulation` — эмулировать поведение терминала.
* `data-debug` — выводить в консоль отладочную информацию.

Пример:


```html
<div id="consolication"
     data-autofocus
     data-ws-server="localhost:3000"
     data-terminal-emulation
     data-debug></div>
```

## Стилизация

Дерево классов выглядит следующим образом:

```
div.consolication
  div.consolication-content
  div.consolication-output
  form.consolication-input
    input.consolication-input-field
```

При включеном эмулировании терминала дерево классов выглядит так:


```
div.consolication.consolication--behaviour-terminal
  div.consolication-content
  div.consolication-output
  form.consolication-input
    input.consolication-input-field
    span.consolication-input-field.consolication-input-field--state-hidden
```

Элемент `span` используется для расчета ширины текста поля ввода.


## Протокол общения с WebSocket сервером

Сообщения отправляются и получается асинхронно не гарантируя порядок
этих сообщений. Все сообщения отправляются без экранирования.
В случае отправки пустого сообщения, отправляется сообщение `__EMPTY__`.
Все получаемые сообщения выводятся без экранирования.
