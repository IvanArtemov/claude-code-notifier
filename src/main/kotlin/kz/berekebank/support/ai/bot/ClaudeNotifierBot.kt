package kz.berekebank.support.ai.bot

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import org.telegram.telegrambots.bots.TelegramLongPollingBot
import org.telegram.telegrambots.meta.api.methods.send.SendMessage
import org.telegram.telegrambots.meta.api.objects.Update

@Component
class ClaudeNotifierBot(
    @Value("\${telegram.bot.token}") private val botToken: String,
    @Value("\${telegram.bot.username}") private val botUsername: String
) : TelegramLongPollingBot(botToken) {

    private val logger = LoggerFactory.getLogger(ClaudeNotifierBot::class.java)

    override fun getBotUsername(): String = botUsername

    override fun onUpdateReceived(update: Update) {
        if (update.hasMessage() && update.message.hasText()) {
            val chatId = update.message.chatId.toString()
            val text = update.message.text

            when {
                text.startsWith("/start") -> {
                    sendNotification(
                        chatId,
                        "Добро пожаловать! Ваш Chat ID: $chatId\n" +
                                "Используйте этот ID для получения уведомлений от Claude Code."
                    )
                }
                text.startsWith("/help") -> {
                    sendNotification(
                        chatId,
                        "Команды бота:\n" +
                                "/start - Получить ваш Chat ID\n" +
                                "/help - Справка\n\n" +
                                "Этот бот получает уведомления о завершении задач Claude Code."
                    )
                }
                else -> {
                    sendNotification(chatId, "Используйте /start или /help для получения информации.")
                }
            }
        }
    }

    fun sendNotification(chatId: String, message: String): Boolean {
        return try {
            val sendMessage = SendMessage.builder()
                .chatId(chatId)
                .text(message)
                .build()
            execute(sendMessage)
            logger.info("Notification sent successfully to chat $chatId")
            true
        } catch (e: Exception) {
            logger.error("Failed to send notification to chat $chatId", e)
            false
        }
    }
}
