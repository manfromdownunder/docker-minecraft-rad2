console.log("Received arguments: ", process.argv);

const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const fs = require('fs');
const https = require('https');
const path = require('path');

puppeteer.use(StealthPlugin());

(async () => {
    try {
        if (process.argv.length < 4) {
            console.error('Please provide a URL and Chrome path as command line arguments.');
            process.exit(1);
        }

        const targetURL = process.argv[2];
        const chromePath = process.argv[3];

        const browser = await puppeteer.launch({
            executablePath: chromePath,
            headless: true
        });

        const page = await browser.newPage();

        await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/53');
        await page.setViewport({ width: 1366, height: 768 });

        await page.setRequestInterception(true);

        page.on('request', async (request) => {
            try {
                if (request.url().endsWith('.zip')) {
                    const urlParts = new URL(request.url());
                    const fileName = path.basename(urlParts.pathname);
                    const folderStructure = process.argv[4];
                    const downloadPath = path.join(folderStructure, fileName);
                    const file = fs.createWriteStream(downloadPath);

                    https.get(request.url(), (response) => {
                        response.pipe(file);

                        file.on('finish', () => {
                            file.close(() => {
                                console.log('Download complete');
                                browser.close();
                                process.exit(0);
                            });
                        });

                        file.on('error', (err) => {
                            console.error("Error writing the file:", err);
                            browser.close();
                            process.exit(1);
                        });
                    }).on('error', (err) => {
                        console.error("Error with HTTP request:", err);
                        browser.close();
                        process.exit(1);
                    });

                    request.continue();
                } else {
                    console.log("Request URL:", request.url());
                    request.continue();
                }
            } catch (error) {
                console.error("An error occurred while handling the request:", error);
            }
        });

        await page.goto(targetURL, { timeout: 0 });
        await page.waitForTimeout(10000);

        await new Promise(resolve => setTimeout(resolve, 10000));
    } catch (error) {
        console.error('An error occurred:', error);
        process.exit(1);
    }
})();
