package kz.vanart.claudenotifier.dto

data class NotificationRequest(
    val chatId: String,
    val message: String
)
