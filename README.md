# Two By Two

The 2×2 matrix is a tool used to help make decisions, identify what’s important or risky and where to focus efforts. It can be used to great effect for product development prioritisation.

It's a graph y'all.

# Development

This repository hosts the front end code for this project.  The backend is
written & hosted in [Dark](http://darklang.com)

## Getting Started

### Requirements

To run the specs or fire up the server, be sure you have instaled:

* node 11.2+ (`brew install node`).

### First Time Setup

After cloning, run:

    $ npm install

### Compiling the code

The client application is written in [Elm](https://elm-lang.org/). Elm
is a statically typed language and must be compiled to javascript. To
compile the code run:

    $ npm elm:make

### Running the Application Locally

The easiest way to run the app is by launching a local http server to
serve up the compiled assets:

    $ npm run http:server
    $ npm elm:make
    $ open http://localhost:3000

### Running the Specs

There is a minimal integration spec suite. In order to run it you will
need to have the local development environment running:

    $ npm run http:server
    $ npm test


### Third Party Services

* [Dark](https://shamus-twoxtwo.builtwithdark.com/) hosted API server
