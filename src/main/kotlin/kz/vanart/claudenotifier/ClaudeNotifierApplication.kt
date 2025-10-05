package kz.vanart.claudenotifier

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class ClaudeNotifierApplication

fun main(args: Array<String>) {
    runApplication<ClaudeNotifierApplication>(*args)
}
