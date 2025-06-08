const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const jwt = require("jsonwebtoken");
require('dotenv').config();
const app = express();
const connectedUsers = new Map();

//this is for the soket
const server = http.createServer(app);  

const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'] // there isn't any more
  }
});


function verifyToken(token) {
  try {
    
    const decoded = jwt.verify(token, process.env.SECRET);
    return decoded;
  } catch (e) {
    console.log("error" + e)
    return null;
  }
}

io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  const user = verifyToken(token);
  if (!user) return next(new Error("Unauthorized"));
  socket.user = user;
  next();
});


io.on('connection', (socket) => {
  const userId = socket.user.id; // Assuming JWT has `id` field
  connectedUsers.set(userId, socket);
  console.log('user connected:', socket.user);
 

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.user);
  });
});
function notifyUser(userId, payload) {
  const userSocket = connectedUsers.get(userId);
  if (userSocket) {
    userSocket.emit('leaveRequestUpdated', payload);
  } else {
    console.log(`User ${userId} not connected.`);
  }
}


const PORT = 9955; //for testing purpose let's use a hardcoded portt
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = { io, notifyUser };