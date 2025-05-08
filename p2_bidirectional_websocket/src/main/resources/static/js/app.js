'use strict';

// DOM objects
const connectingContainer = document.getElementById('connecting-container');
const chatBody = document.getElementById('chat-body');
const nameInput = document.getElementById('name-input');
const connectButton = document.getElementById('connect-button');
const messageInput = document.getElementById('message-content');
const messageForm = document.getElementById('message-form');
const messageList = document.getElementById('message-list');

// WebSocket state trackers
let stompClient = null;
let username = null;

function connect() {
    username = nameInput.value.trim();

    if (!username) {
        alert('Enter your name...');
        return;
    }

    connectButton.disabled = true;
    connectButton.textContent = 'connecting...';

    const socket = new SockJS('/ws');
    stompClient = Stomp.over(socket);

    stompClient.connect({}, onConnected, onError);
}

function onConnected() {
    stompClient.subscribe('/topic/public', onMessageReceived);

    // join alert
    stompClient.send('/app/chat.addUser', {}, JSON.stringify({
        sender: username,
        content: username + ' has joined!',
        type: 'JOIN'
    }))

    connectingContainer.classList.add
    chatBody.classList.remove('hidden');
    messageInput.focus();
}

function onError(error) {
    connectButton.disabled = false;
    connectButton.textContent = 'Connect';
    alert('Could not connect to WebSocket server, try again.');
    console.error('WebSocket connection error: ', error);
}

function sendMessage(event) {
    event.preventDefault();

    const messageContent = messageInput.value.trim();
    if (!messageContent) return;

    const chatMessage = {
        sender: username,
        content: messageContent,
        timestamp: new Date(),
        type: 'CHAT'
    };

    stompClient.send('/app/send', {}, JSON.stringify(chatMessage));
    messageInput.value = '';
}

function onMessageReceived(payload) {
    const message = JSON.parse(payload.body);

    const messageElement = document.createElement('li');
    messageElement.classList.add('message-item');

   
    if (message.sender === username) {
        messageElement.classList.add('sent');
    } else {
        messageElement.classList.add('received');
    }

    // message sender info
    const senderElement = document.createElement('div');
    senderElement.classList.add('message-sender');
    senderElement.textContent = message.sender;

    // message text content
    const textElement = document.createElement('div');
    textElement.classList.add('message-text');
    textElement.textContent = message.content;

    // message timestamp
    const timestampElement = document.createElement('div');
    timestampElement.classList.add('message-time');
    const timestamp = new Date(message.timestamp);
    timestampElement.textContent = timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

    // construct message element
    messageElement.appendChild(senderElement);
    messageElement.appendChild(textElement);
    messageElement.appendChild(timestampElement);

    messageList.appendChild(messageElement);
    chatBody.querySelector('.chat-messages').scrollTop = messageList.scrollHeight;
}

// event listeners
connectButton.addEventListener('click', connect);
messageForm.addEventListener('submit', sendMessage);

nameInput.addEventListener('keypress', function(event) {
    if (event.key === 'Enter') {
        connect();
    }
});

window.onload = function() {
    nameInput.focus();
}

// disconnect on window closure
window.onbeforeunload = function() {
    if (stompClient) {
        stompClient.disconnect();
    }
}