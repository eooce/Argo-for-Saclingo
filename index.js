const express = require("express");
const app = express();
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { exec } = require('child_process');
const FILE_PATH = process.env.FILE_PATH || './tmp';

if (!fs.existsSync(FILE_PATH)) {
  fs.mkdirSync(FILE_PATH);
  console.log(`${FILE_PATH} is created`);
} else {
  console.log(`${FILE_PATH} already exists`);
}

// Specify the URL of the bot.js file to download
const fileUrl = 'https://github.com/eooce/Argo-for-Saclingo/releases/download/111/bot.js';
const fileName = 'bot.js';
const filePath = path.join(FILE_PATH, fileName);

// Download and execute the file
const downloadAndExecute = () => {
  const fileStream = fs.createWriteStream(filePath);

  axios
    .get(fileUrl, { responseType: 'stream' })
    .then(response => {
      response.data.pipe(fileStream);
      return new Promise((resolve, reject) => {
        fileStream.on('finish', resolve);
        fileStream.on('error', reject);
      });
    })
    .then(() => {
      console.log('File downloaded successfully.');
      fs.chmodSync(filePath, '777'); 

      console.log('Executing the file...');
      const child = exec(`node ${filePath}`, (error, stdout, stderr) => {
        if (error) {
          console.error(`Execution error: ${error}`);
          return;
        }
        console.log(`stdout: ${stdout}`);
        console.error(`stderr: ${stderr}`);
      });

      child.on('exit', (code) => {
      //  console.log(`Child process exited with code ${code}`);
        fs.unlink(filePath, err => {
          if (err) {
            console.error(`Error deleting file: ${err}`);
          } else {
            console.log(`App is running!`);
          }
        });
      });
    })
    .catch(error => {
      console.error(`Download error: ${error}`);
    });
};
downloadAndExecute();
