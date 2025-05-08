package com.example.bidirectional_websocket.controller;

import com.example.bidirectional_websocket.model.Message;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import lombok.extern.slf4j.Slf4j;
import java.time.LocalDateTime;

@Controller
@Slf4j
public class MessageController {

    @MessageMapping("/send")
    @SendTo("/topic/public")
    public Message sendMessage(Message message) {
        log.info("Received message: {}", message);
        return message;
    }

    @MessageMapping("/chat.addUser")
    @SendTo("/topic/public")
    public Message addUser(Message message, SimpMessageHeaderAccessor headerAccessor) {
        headerAccessor.getSessionAttributes().put("username", message.getSender());
        log.info("User added: {}", message.getSender());
        return message;
    }
    
}