package kz.berekebank.support.ai.config

import kz.berekebank.support.ai.bot.ClaudeNotifierBot
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Configuration
import org.springframework.context.event.ContextRefreshedEvent
import org.springframework.context.event.EventListener
import org.telegram.telegrambots.meta.TelegramBotsApi
import org.telegram.telegrambots.meta.exceptions.TelegramApiException
import org.telegram.telegrambots.updatesreceivers.DefaultBotSession

@Configuration
class TelegramBotInitializer(
    private val claudeNotifierBot: ClaudeNotifierBot
) {
    private val logger = LoggerFactory.getLogger(TelegramBotInitializer::class.java)

    @EventListener(ContextRefreshedEvent::class)
    fun init() {
        try {
            val telegramBotsApi = TelegramBotsApi(DefaultBotSession::class.java)
            telegramBotsApi.registerBot(claudeNotifierBot)
            logger.info("Telegram bot registered successfully!")
        } catch (e: TelegramApiException) {
            logger.error("Error registering Telegram bot", e)
        }
    }
}
