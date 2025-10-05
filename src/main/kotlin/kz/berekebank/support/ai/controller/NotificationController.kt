package kz.berekebank.support.ai.controller

import kz.berekebank.support.ai.dto.NotificationRequest
import kz.berekebank.support.ai.dto.NotificationResponse
import kz.berekebank.support.ai.service.NotificationService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api")
class NotificationController(
    private val notificationService: NotificationService
) {

    @PostMapping("/notify")
    fun notify(@RequestBody request: NotificationRequest): ResponseEntity<NotificationResponse> {
        val response = notificationService.sendNotification(request)

        return if (response.success) {
            ResponseEntity.ok(response)
        } else {
            ResponseEntity.status(500).body(response)
        }
    }

    @GetMapping("/health")
    fun health(): ResponseEntity<Map<String, String>> {
        return ResponseEntity.ok(mapOf("status" to "UP"))
    }
}
