package com.example.bidirectional_websocket;

import org.springframework.boot.SpringApplication;

public class TestBidirectionalWebsocketApplication {

	public static void main(String[] args) {
		SpringApplication.from(BidirectionalWebsocketApplication::main).with(TestcontainersConfiguration.class).run(args);
	}

}
