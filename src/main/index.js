import { BrowserWindow, app, ipcMain, shell } from 'electron';
import { electronApp, is, optimizer } from '@electron-toolkit/utils';
import { join } from 'path';
import fs from 'fs';
import icon from '../../resources/Temtem_Logo.ico?asset';

const dirPath = join(__dirname, '../../resources/json'); // directory to watch
const fileName = 'temdata.json'; // file to watch

let mainWindow;

function createWindow() {
    // Create the browser window.
    mainWindow = new BrowserWindow({
        width: 900,
        height: 900,
        show: false,
        autoHideMenuBar: true,
        icon,
        webPreferences: {
            preload: join(__dirname, '../preload/index.js'),
            sandbox: false,
            backgroundThrottling: false,
            nodeIntegration: true,
        },
    });

    fs.watch(dirPath, (event, changedFileName) => {
        if (changedFileName === fileName) {
            const filePath = join(dirPath, changedFileName);

            try {
                fs.readFile(filePath, 'utf-8', (err, data) => {
                    if (err) {
                        console.error(`[temJson:read] unable to read file?`, err);
                        mainWindow.webContents.send('temJson:error', err);
                        return;
                    }

                    // Success: file read
                    mainWindow.webContents.send('temJson:updated', JSON.parse(data));
                });
            } catch (err) {
                console.error(`[temJson:read] unable to read file?`, err);
                mainWindow.webContents.send('temJson:error', err);
            }
        }
    });

    mainWindow.on('ready-to-show', () => {
        mainWindow.show();
    });

    mainWindow.webContents.setWindowOpenHandler(details => {
        shell.openExternal(details.url);
        return { action: 'deny' };
    });

    // HMR for renderer base on electron-vite cli.
    // Load the remote URL for development or the local html file for production.
    if (is.dev && process.env['ELECTRON_RENDERER_URL']) {
        mainWindow.loadURL(process.env['ELECTRON_RENDERER_URL']);
    } else {
        mainWindow.loadFile(join(__dirname, '../renderer/index.html'));
    }
}

app.commandLine.appendSwitch('disable-renderer-backgrounding');
app.commandLine.appendSwitch('disable-background-timer-throttling');

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
    // Set app user model id for windows
    electronApp.setAppUserModelId('com.electron');

    // Default open or close DevTools by F12 in development
    // and ignore CommandOrControl + R in production.
    // see https://github.com/alex8088/electron-toolkit/tree/master/packages/utils
    app.on('browser-window-created', (_, window) => {
        optimizer.watchWindowShortcuts(window);
    });

    createWindow();

    app.on('activate', function () {
        // On macOS it's common to re-create a window in the app when the
        // dock icon is clicked and there are no other windows open.
        if (BrowserWindow.getAllWindows().length === 0) createWindow();
    });
});

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

ipcMain.on('temJson:read', (event, args) => {
    if (fs.existsSync(dirPath)) {
        const filePath = join(dirPath, fileName);

        try {
            if (!fs.existsSync(filePath)) {
                console.debug(`[temJson:read] file does not exist`);
                mainWindow.webContents.send('temJson:exists', false);
                return;
            }

            // Success: file exists
            mainWindow.webContents.send('temJson:exists', true);
        } catch (err) {
            console.error(`[temJson:read] unable to find file?`, err);
            mainWindow.webContents.send('temJson:exists', false);
        }

        try {
            fs.readFile(filePath, 'utf-8', (err, data) => {
                if (err) {
                    console.error('There was an error reading the file!', err);
                    mainWindow.webContents.send('temJson:error', err);
                    return;
                }
                // Success: file read
                mainWindow.webContents.send('temJson:updated', JSON.parse(data));
            });
        } catch (err) {
            console.error(`[temJson:read] unable to read file?`, err);
            mainWindow.webContents.send('temJson:error', err);
        }
    } else {
        mainWindow.webContents.send('temJson:exists', false);
    }
});
