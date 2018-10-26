/**
 * This file is the main runtime javascript code for the app.
 * It is loaded by index.html and instantiates the elm app.
 */

const exec = require('child_process').exec
const remote = require('electron').remote

window.onload = function () {
    // Launch the elm app
    var app = Elm.Main.init({
        node: document.getElementById('elm')
    });

    // Handle drag+drop files from desktop
    // TODO: electron has APIs for this that probably work better
    document.body.addEventListener(
        'dragover',
        function handleDragOver(evt) {
            evt.stopPropagation()
            evt.preventDefault()
            evt.dataTransfer.dropEffect = 'copy'
        },
        false
    )
    document.body.addEventListener(
        'drop',
        function (evt) {
            evt.stopPropagation()
            evt.preventDefault()
            var files = evt.dataTransfer.files  // FileList object.
            if (files.length > 0) {
                var file = files[0]                 // File     object.
                app.ports.fileDropped.send(file.name)
            }
        },
        false
    )

    app.ports.debugExperementalSendElectromMsg.subscribe((cmdString) => {
        exec(cmdString, (error, stdout, stderr) => {
            if (error) {
                app.ports.debugExperementalElectromMsg.send(
                    `${cmdString}: ■ exec error: ${error}`
                )
            } else {
                app.ports.debugExperementalElectromMsg.send(`${cmdString}: ■ ${stdout}`)
            }
        });
    })
}


/**
 * DEBUG
 * 
 * binds pressing F12 to opening the Chrome developer tools
 * and F5 to reloading the page.
 */
document.addEventListener("keydown", function (e) {
    if (e.which === 123) {
        require('electron').remote.getCurrentWindow().toggleDevTools();
    } else if (e.which === 116) {
        location.reload();
    }
});