/**
 * This is the entry point for the electron app. It opens
 * a window and loads `index.html` in that window.
 * 
 * Most JS code should probably be in other files that
 * are liked to by index.html. Those are run in Chromium;
 * this runs in NodeJS. Electron calls those the 
 * "renderer/render thread"; this is the "main thread".
 * 
 */

const { app, BrowserWindow } = require('electron')


function createWindow() {
    // Create the browser window.
    let win = new BrowserWindow({ width: 800, height: 600, nodeIntegration: true })
    win.setMenu(null);

    // and load the index.html of the app.
    win.loadFile('index.html')

    win.on('closed', () => {
        // Dereference the window object, usually you would store windows
        // in an array if your app supports multi windows, this is the time
        // when you should delete the corresponding element.
        win = null
    })

    app.on('window-all-closed', () => {
        // macOS users might expect you to keep the program
        // open even when all the windows are closed, but 
        // I'm just quitting it for now.
        app.quit()
    })
}

app.on('ready', createWindow)