# TemScanner-Electron

Temtem UI assistant (Electron web app) for automatically displaying Wiki/API data using OCR text recognition (via Autohotkey).

## Disclaimer

-   Does **NOT** read game memory
-   Does **NOT** automate any in-game functionality
-   Does **NOT** send any requests to game
-   Does **NOT** intercept any game data
-   Will **NOT** get you banned

## How it works

-   Loads the Temtem API data available at https://temtem-api.mael.tech/ to populate Temtem information to the webapp UI
-   Uses [Autohotkey v1](https://www.autohotkey.com/) and the [Windows built-in OCR](https://learn.microsoft.com/en-us/uwp/api/windows.media.ocr?view=winrt-22621) methods to read the Temtem name labels from the game windows
    -  Autohotkey uses pixel detection to determine if the game is currently in battle and which Temtem is currently active on the enemy side. Currently it only supports 1440p and 1080p resolutions. More will likely be added with testing.
    -  Autohotkey outputs the OCR text recognition result to a JSON file in the `temscanner-electron\resources\app.asar.unpacked\resources\AutoHotkey` folder
        - To reduce writes to the local disk, the JSON file is only written to during combat
    -  The Electron app (the web application exe itself) reads the JSON file whenever it changes, and matches against the data populated from the API data noted above

## Notes
-  The OCR isn't perfect! A dedicated, 3rd party OCR engine that supports Temtem's custom font better would likely improve accuracy. But currently the matching works in most combat scenarios. The moving battle camera can sometimes struggle, but the OCR will retry every 1 second.
-  The internal JavaScript logic has pre-configuration for OCR patterns based on play testing, and matches Tem names at ~80% confidence
-  Please don't blindly run EXE files provided from the internet when possible. Look through the source code, and build the app yourself if you are not comfortable with the provided EXE file.
-  The Autohotkey script can also be separately built if you have [Autohotkey v1](https://www.autohotkey.com/) installed
    - Navigate to the `temscanner-electron\resources\app.asar.unpacked\resources\AutoHotkey` folder, right-click the `TemScanner.ahk` file, and select `Compile Script` to build the EXE file

## Project Setup

### Recommended IDE Setup

-   [VSCode](https://code.visualstudio.com/) + [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) + [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)


### CLI Prerequisites

-   [Node.js](https://nodejs.org/en/) (v18.16.x)
-   [Yarn](https://yarnpkg.com/) (v1.22.x)

### Built using

-   [Electron](https://www.electronjs.org/)
-   [Vue 3](https://vuejs.org/)
-   [Vite](https://vitejs.dev/)
-   [electron-vite](https://evite.netlify.app/)
-   [Autohotkey v1](https://www.autohotkey.com/)

### Install

```bash
$ yarn install
```

### Development

```bash
$ yarn dev
```

### Build

```bash
# For windows (the only currently targeted OS)
$ npm run build:win
```
