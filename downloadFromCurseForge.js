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

                const urlParts = new URL(request.url());
                const fileName = path.basename(urlParts.pathname);
                const downloadPath = path.join(folderStructure, fileName);
                const file = fs.createWriteStream(downloadPath);

                https.get(request.url(), (response) => {
                    response.pipe(file);

                    file.on('finish', async () => {
                        file.close(async () => {
                            console.log('Download complete');
                            console.log('DownloadedFilePath:', downloadPath);

                            movedZipPath = path.join(minecraftServerPath, fileName);
                            await fsPromises.rename(downloadPath, movedZipPath);
                            console.log('ZIP moved to minecraft-server');

                            await unzipFile(movedZipPath, minecraftServerPath);
                            console.log('Unzip complete');

                            const directories = await fsPromises.readdir(minecraftServerPath, { withFileTypes: true })
                                .then(dirs => dirs.filter(d => d.isDirectory()).map(d => d.name));

                            if (directories.length === 0) {
                                console.log('No subdirectories found. Nothing to move.');
                                return;
                            }

                            const subFolderName = directories[0];
                            const srcDir = path.join(minecraftServerPath, subFolderName);

                            await moveFiles(srcDir, minecraftServerPath);
                            console.log('Contents moved to minecraft-server root.');

                            // Clean up: Remove the empty subdirectory and the ZIP file
                            await fsPromises.rmdir(srcDir);
                            await fsPromises.unlink(movedZipPath);
                            console.log('Cleanup complete.');
                        });
                    });
                });

                request.continue();
            } else {
                console.log("Request URL:", request.url());
                request.continue();
            }
        });

        await page.goto(targetURL, { timeout: 0 });
        await page.waitForTimeout(10000);

        await browser.close();
    } catch (error) {
        console.error('An error occurred:', error);
        process.exit(1);
    }
})();
