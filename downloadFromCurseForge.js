console.log("Received arguments: ", process.argv);

const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const fsPromises = require('fs').promises;
const fs = require('fs');
const https = require('https');
const path = require('path');
const unzipper = require('unzipper');

puppeteer.use(StealthPlugin());

let isDownloadStarted = false;  // Flag to know if download has started

async function unzipFile(filePath, destDir) {
    return new Promise((resolve, reject) => {
        fs.createReadStream(filePath)
            .pipe(unzipper.Extract({ path: destDir }))
            .on('close', resolve)
            .on('error', reject);
    });
}

async function moveFiles(srcDir, destDir) {
    const files = await fsPromises.readdir(srcDir);
    const movePromises = files.map(file => {
        const srcPath = path.join(srcDir, file);
        const destPath = path.join(destDir, file);
        return fsPromises.rename(srcPath, destPath);
    });
    return Promise.all(movePromises);
}

(async () => {
    try {
        if (process.argv.length < 4) {
            console.error('Please provide a URL and Chrome path as command line arguments.');
            process.exit(1);
        }

        const targetURL = process.argv[2];
        const chromePath = process.argv[3];
        const folderStructure = process.argv[4] || ".";
        const minecraftServerPath = path.join(__dirname, 'minecraft-server');

        if (!fs.existsSync(minecraftServerPath)) {
            fs.mkdirSync(minecraftServerPath);
        }

        const browser = await puppeteer.launch({
            executablePath: chromePath,
            headless: true,
            args: ['--no-sandbox', '--disable-setuid-sandbox'],
        });

        const page = await browser.newPage();

        await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/53');
        await page.setViewport({ width: 1366, height: 768 });

        await page.setRequestInterception(true);

        let movedZipPath = '';  // Store moved ZIP path for deletion later

        page.on('request', async (request) => {
            if (isDownloadStarted) {
                request.abort();  // Abort all new requests once download starts
                return;
            }

            if (request.url().endsWith('.zip')) {
                isDownloadStarted = true;  // Set the flag here

                // ... (Rest of the code remains unchanged)
            } else {
                console.log("Request URL:", request.url());
                request.continue();
            }
        });

        await page.goto(targetURL, { timeout: 0 });
        await page.waitForTimeout(10000);

        await browser.close();
    } catch (error) {
        if (error.message && error.message.includes("Navigation failed because browser has disconnected")) {
            console.warn('Ignoring browser disconnection error.');
            process.exit(0);  // Exit with status code 0, indicating a 'successful' run despite the issue
        } else {
            console.error('An error occurred:', error);
            process.exit(1);  // Exit with status code 1, indicating an error
        }
    }
})();
