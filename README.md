Nodemud MUD engine for NodeJS
=============================
A fully featured MUD engine written in Coffeescript for NodeJS.

## Why?

I'm a huge NodeJS/Coffeescript fan, and I spend most of my work day writing code in it. I've also been playing
MUD's for nearly two decades now, and I've been itching to write one from scratch for years.

NodeJS is fast, powerful, and easy to work in. Combined with Coffeescript's classes and a dead simple
package management system, it seemed like a natural fit.

## Features

- Player creation, saving, loading, and passwords.
- Room creation, saving, and loading.
- Movement.
- In-game map.
- Building prompts.
- Looking.

## Todo

- Virtually everything that has to do with players, including stats, health, combat, etc.
- NPC's
- Objects
- ~~Configuration (hard coded to my dev env, etc)~~

## Installation

Install all the deps:

`npm install`

then run:

`coffee bin/nodemud.coffee`

and you're all set! By default, the MUD will listen on port 4000; use your favorite MUD client to connect.