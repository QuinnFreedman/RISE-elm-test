# RISE Editor -- Elm

## Setup

1. Install NodeJS. It should come with a version of NPM, the node package manager/build system.

2. `cd` here and run `npm install`. This will install all the dependencies from `package.json`.

3. If you want to install Elm globally you can run `npm i -g elm` (make sure npm's bin package directory is in your PATH). But, you can also use the project-local binary at `./node_modules/.bin/elm`. There is a `npm` script for this; just run `npm run elm --` (You need the `--` to pass arguments to elm).

4. To compile the elm app, run `npm run build`.

5. To launch the electron app, run `npm start`.

> Note: Elm 19 added caching and partial builds to the compiler. Sometimes they go wrong. If you get weird compiler errors or ANY runtime errors, just `rm -rf elm-stuff`. I made `npm run clean` to do this also.

6. Running `elm reactor` makes a nice development server that will show you your errors in the browser in real time. But, as we get more into electron the capabilities of the browser app will probably diverge from the real app.

## Editor

Right now, VSCode and IntelliJ were the only editors I could find that supported Elm 19 and IntelliJ's plugin was buggy. Atom's support is great though when it catches up.

Whatever you use, I recommend using `elm-format` to keep formatting consistent. It is also a local dependency if you don't want to install anything globally.

## Files

* `package.json` - defines the NodeJS project. It defines NPM dependencies and cli scripts.
* `elm.json` - defines the Elm project and Elm dependencies.
* `launcher.js` - The entry point for the NodeJS app. Launches electron with `index.html`.
* `app.js` - The main code for the JavaScript side of the app. Launches the Elm app.
* `src/` - All of the code for the Elm app. `Main.elm` is the entry point.