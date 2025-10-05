# Claude Code Notifier Bot

Telegram бот для получения уведомлений о завершении задач в Claude Code.

## Возможности

- 📱 Отправка уведомлений в Telegram при завершении задач Claude Code
- 🔌 REST API эндпоинт для приема уведомлений
- ⚡ Автоматическая интеграция через хуки Claude Code
- 🤖 Telegram бот с командами `/start` и `/help`
- 🎯 Два типа уведомлений: завершение сессии и ожидание ввода

## Технологии

- **Kotlin** 2.1.10
- **Spring Boot** 3.2.0
- **Spring Web MVC**
- **Telegram Bots** 6.7.0

## 🚀 Быстрый старт

### Автоматическая установка (Рекомендуется)

Самый простой способ - использовать интерактивную установку через Claude Code:

```bash
/notifier-setup
```

Эта команда проведет вас через весь процесс установки:
- ✅ Проверит все необходимые компоненты
- ✅ Запросит данные Telegram бота
- ✅ Настроит конфигурацию
- ✅ Соберет и запустит приложение
- ✅ Установит глобальные хуки Claude Code
- ✅ Протестирует работу

**Другие полезные команды:**
- `/notifier-start` - Запустить сервис
- `/notifier-stop` - Остановить сервис
- `/notifier-status` - Проверить статус
- `/notifier-test` - Отправить тестовое уведомление
- `/notifier-uninstall` - Удалить все компоненты

Подробнее о командах см. [.claude/commands/README.md](.claude/commands/README.md)

---

## 📝 Ручная установка и настройка

### 1. Создание Telegram бота

1. Найдите [@BotFather](https://t.me/botfather) в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям и получите токен бота
4. Сохраните токен и имя бота

### 2. Получение Chat ID

1. Запустите приложение (см. раздел "Запуск")
2. Найдите своего бота в Telegram
3. Отправьте команду `/start`
4. Бот вернет ваш Chat ID

### 3. Настройка переменных окружения

Создайте переменные окружения или настройте в `application.yml`:

```bash
export TELEGRAM_BOT_TOKEN="your-bot-token-here"
export TELEGRAM_BOT_USERNAME="YourBotUsername"
export TELEGRAM_CHAT_ID="your-chat-id"
```

### 4. Настройка Claude Code Hook

Отредактируйте файл `.claude/settings.json`:

```json
{
  "hooks": {
    "on-task-complete": ".claude/hooks/task-complete.sh"
  },
  "env": {
    "TELEGRAM_CHAT_ID": "your-chat-id-here",
    "CLAUDE_NOTIFIER_URL": "http://localhost:8080/api/notify"
  }
}
```

## Запуск приложения

### Использование Gradle

```bash
./gradlew bootRun
```

### Сборка JAR

```bash
./gradlew build
java -jar build/libs/ClaudeNotifier-1.0-SNAPSHOT.jar
```

Приложение запустится на порту **8080**.

## API Endpoints

### POST /api/notify
Отправить уведомление в Telegram

**Request:**
```json
{
  "chatId": "123456789",
  "message": "Task completed successfully!"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Notification sent successfully"
}
```

### GET /api/health
Проверка состояния сервиса

**Response:**
```json
{
  "status": "UP"
}
```

## Как это работает

### Уведомление о завершении сессии (Stop Hook)

1. Claude Code завершает ответ пользователю
2. Срабатывает хук `Stop` в `~/.claude/settings.json`
3. Скрипт `.claude/hooks/task-complete.sh` анализирует transcript файл
4. Извлекается информация: последний запрос, количество инструментов, сообщений
5. HTTP запрос отправляется на `/api/notify`
6. Spring контроллер принимает запрос и передает в Telegram бот
7. Вы получаете уведомление в Telegram с информацией о сессии! 📊

### Уведомление об ожидании ввода (Notification Hook)

1. Claude Code простаивает более 60 секунд (ждет ввода пользователя)
2. Срабатывает хук `Notification`
3. Скрипт `.claude/hooks/notification.sh` извлекает последний вопрос Claude
4. HTTP запрос отправляется на `/api/notify`
5. Вы получаете уведомление что Claude ждет вашего ответа! ⏸️

## Структура проекта

```
ClaudeNotifier/
├── .claude/
│   ├── commands/                           # Slash команды
│   │   ├── README.md                       # Документация команд
│   │   ├── notifier-setup.md              # Интерактивная установка
│   │   ├── notifier-start.md              # Запуск сервиса
│   │   ├── notifier-stop.md               # Остановка сервиса
│   │   ├── notifier-status.md             # Проверка статуса
│   │   ├── notifier-test.md               # Тестовое уведомление
│   │   └── notifier-uninstall.md          # Удаление
│   ├── hooks/
│   │   ├── task-complete.sh               # Хук завершения сессии (Stop)
│   │   └── notification.sh                # Хук ожидания ввода (Notification)
│   └── settings.json                      # Конфигурация хуков (локальная)
├── src/main/
│   ├── kotlin/kz/berekebank/support/ai/
│   │   ├── ClaudeNotifierApplication.kt   # Main класс
│   │   ├── bot/
│   │   │   └── ClaudeNotifierBot.kt       # Telegram бот
│   │   ├── config/
│   │   │   └── TelegramBotInitializer.kt  # Инициализация бота
│   │   ├── controller/
│   │   │   └── NotificationController.kt  # REST контроллер
│   │   ├── dto/
│   │   │   ├── NotificationRequest.kt     # DTO запроса
│   │   │   └── NotificationResponse.kt    # DTO ответа
│   │   └── service/
│   │       └── NotificationService.kt     # Сервис уведомлений
│   └── resources/
│       ├── application.yml                # Конфигурация (база)
│       └── application-local.yml          # Конфигурация (с токенами, gitignored)
└── build.gradle.kts

Глобальные файлы (установленные через /notifier-setup):
~/.claude/
├── settings.json                          # Глобальные хуки и env переменные
└── hooks/
    ├── task-complete.sh                   # Копия Stop хука
    └── notification.sh                    # Копия Notification хука
```

## Telegram Bot команды

- `/start` - Получить ваш Chat ID и приветственное сообщение
- `/help` - Справка по использованию бота

## Примеры уведомлений

### Завершение сессии
```
✅ Claude Code Session Completed

📝 Request: мне нужен телеграмм бот который будет посылать уведомления...

🔧 Tools used: 25
💬 Messages: 48
⏰ Completed: 2025-10-05 14:30:45
```

### Ожидание ввода
```
⏸️ Claude Code Waiting for Input

❓ Message: Would you like me to send a test notification to verify everything works?

🆔 Session: abc123-def456
⏰ Time: 2025-10-05 14:32:10
```

## Troubleshooting

### Бот не отправляет сообщения
- Проверьте правильность токена бота в переменных окружения
- Убедитесь, что приложение запущено
- Проверьте логи приложения на наличие ошибок

### Хук не срабатывает
- Убедитесь, что скрипт имеет права на выполнение: `chmod +x .claude/hooks/task-complete.sh`
- Проверьте правильность переменной `TELEGRAM_CHAT_ID` в `.claude/settings.json`
- Проверьте, что URL бота доступен

### Chat ID не приходит
- Убедитесь, что бот запущен
- Отправьте `/start` еще раз
- Проверьте имя бота (username) в настройках

## Лицензия

Этот проект создан для внутреннего использования.
