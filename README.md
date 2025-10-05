# Claude Code Notifier Bot

Telegram бот для получения уведомлений о завершении задач в Claude Code.

## Возможности

- 📱 Отправка уведомлений в Telegram при завершении задач Claude Code
- 🔌 REST API эндпоинт для приема уведомлений
- ⚡ Автоматическая интеграция через хуки Claude Code
- 🤖 Telegram бот с командами `/start` и `/help`

## Технологии

- **Kotlin** 2.1.10
- **Spring Boot** 3.2.0
- **Spring Web MVC**
- **Telegram Bots** 6.7.0

## Установка и настройка

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

1. При завершении задачи в Claude Code срабатывает хук `on-task-complete`
2. Скрипт `.claude/hooks/task-complete.sh` отправляет HTTP запрос на `/api/notify`
3. Spring контроллер принимает запрос и передает в сервис
4. Telegram бот отправляет сообщение указанному пользователю
5. Вы получаете уведомление в Telegram! 🎉

## Структура проекта

```
ClaudeNotifier/
├── .claude/
│   ├── hooks/
│   │   └── task-complete.sh          # Хук для Claude Code
│   └── settings.json                 # Конфигурация хука
├── src/main/
│   ├── kotlin/kz/berekebank/support/ai/
│   │   ├── ClaudeNotifierApplication.kt    # Main класс
│   │   ├── bot/
│   │   │   └── ClaudeNotifierBot.kt        # Telegram бот
│   │   ├── controller/
│   │   │   └── NotificationController.kt   # REST контроллер
│   │   ├── dto/
│   │   │   ├── NotificationRequest.kt      # DTO запроса
│   │   │   └── NotificationResponse.kt     # DTO ответа
│   │   └── service/
│   │       └── NotificationService.kt      # Сервис уведомлений
│   └── resources/
│       └── application.yml                 # Конфигурация приложения
└── build.gradle.kts
```

## Telegram Bot команды

- `/start` - Получить ваш Chat ID и приветственное сообщение
- `/help` - Справка по использованию бота

## Пример уведомления

```
✅ Claude Code Task Completed

📋 Summary: Implemented user authentication feature

⏰ Completed at: 2025-10-05 14:30:45
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
