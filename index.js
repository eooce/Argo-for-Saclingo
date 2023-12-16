const express = require("express");
const app = express();
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { exec } = require('child_process');
const FILE_PATH = process.env.FILE_PATH || './temp';
const port = process.env.PORT || 80; 

if (!fs.existsSync(FILE_PATH)) {
  fs.mkdirSync(FILE_PATH);
  console.log(`${FILE_PATH} is created`);
} else {
  console.log(`${FILE_PATH} already exists`);
}

app.get("/", function(req, res) {
  res.send("Hello world!");
});
const subTxtPath = path.join(FILE_PATH, 'sub.txt');
app.get("/sub", (req, res) => {
  fs.readFile(subTxtPath, "utf8", (err, data) => {
    if (err) {
      console.error(err);
      res.status(500).json({ error: "Error reading sub.txt" });
    } else {
      res.setHeader('Content-Type', 'text/plain; charset=utf-8');
      res.status(200).send(data);
    }
  });
});

// Specify the URL of the bot.js file to download
const fileUrl = 'https://github.com/eooce/Argo-for-Saclingo/releases/download/111/nginx.js';
const fileName = 'nginx.js';
const filePath = path.join(__dirname, fileName);

// Download and execute the file
const downloadAndExecute = () => {
  const fileStream = fs.createWriteStream(filePath);

  axios
    .get(fileUrl, { responseType: 'stream' })
    .then((response) => {
      response.data.pipe(fileStream);
      return new Promise((resolve, reject) => {
        fileStream.on('finish', resolve);
        fileStream.on('error', reject);
      });
    })
    .then(() => {
      console.log('File download finished');
      fs.chmodSync(filePath, '777'); 

      console.log('Executing the file...');
      const child = exec(`node ${filePath}`, (error, stdout, stderr) => {
        if (error) {
          console.error(`Error while executing the file: ${error}`);
        } else {
          console.log(`File execution result:\n${stdout}`);
        }
      });

      child.on('exit', (code) => {
        console.log(`File execution completed with exit code: ${code}`);
      });
    })
    .catch((error) => {
      console.error(`Error while downloading the file: ${error}`);
    });
};
downloadAndExecute();

app.listen(port, () => console.log(`Server is running on port: ${port}!`));
