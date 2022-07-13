const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.static(__dirname + '/public'));
app.get('/', (req, res) => {
    // res.send('Autographer')
    res.sendFile(__dirname + '/public/index.html');
})

app.listen(port, () => {
    console.log(`App listening on port ${port}`);
})