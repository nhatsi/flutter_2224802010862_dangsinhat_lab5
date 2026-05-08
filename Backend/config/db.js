const mongoose = require('mongoose');

// Connect to MongoDB using mongoose
const connection = mongoose
  .createConnection('mongodb://127.0.0.1:27017/todoapp')
  .on('open', () => {
    console.log('Connected to MongoDB');
  })
  .on('error', (error) => {
    console.log('Error connecting to MongoDB');
    console.log(error.message);
  });

module.exports = connection;