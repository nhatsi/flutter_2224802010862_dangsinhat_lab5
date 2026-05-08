const app = require('./app');
require('./config/db');

const port = 3000;

app.get('/', (req, res) => {
  res.send('Backend API is running');
});

app.listen(port, () => {
  console.log(`Server running on port http://localhost:${port}`);
});