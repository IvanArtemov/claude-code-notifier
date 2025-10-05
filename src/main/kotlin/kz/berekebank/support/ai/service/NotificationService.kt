package kz.berekebank.support.ai.service

import kz.berekebank.support.ai.bot.ClaudeNotifierBot
import kz.berekebank.support.ai.dto.NotificationRequest
import kz.berekebank.support.ai.dto.NotificationResponse
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class NotificationService(
    private val bot: ClaudeNotifierBot
) {
    private val logger = LoggerFactory.getLogger(NotificationService::class.java)

    fun sendNotification(request: NotificationRequest): NotificationResponse {
        logger.info("Sending notification to chatId: ${request.chatId}")

        val success = bot.sendNotification(request.chatId, request.message)

        return if (success) {
            NotificationResponse(
                success = true,
                message = "Notification sent successfully"
            )
        } else {
            NotificationResponse(
                success = false,
                message = "Failed to send notification"
            )
        }
    }
}
