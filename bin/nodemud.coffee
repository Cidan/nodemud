#!/usr/bin/coffee
process.chdir "#{__dirname}/../"
global.hub = require '../lib/hub'
hub.start()