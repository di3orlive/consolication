loadGruntTasks = require "load-grunt-tasks"


module.exports = (grunt) ->
  loadGruntTasks grunt

  grunt.initConfig
    clean:
      server: ".tmp"
      build: "build"
    jade:
      server:
        files: 
          ".tmp/index.html": "src/index.jade"
    stylus:
      server:
        files:
          ".tmp/index.css": "src/index.styl"
    browserify:
      options:
        transform: [
          "coffeeify"
        ]
      vendor:
        options:
          alias: [
            "node_modules/react-tools/build/modules/React.js:React"
          ]
        files:
          ".tmp/vendor.js": [
            "node_modules/react-tools/build/modules/React.js" 
          ]
      server:
        options:
          external: [
            "React"
          ]
        files:
          ".tmp/index.js": "src/index.coffee"
    express:
      options:
        hostname: "0.0.0.0"
      server:
        options:
          server: "server"
          bases: ".tmp"
          livereload: true
    watch:
      jade:
        files: "src/*.jade"
        tasks: "jade"
      stylus:
        files: "src/*.styl"
        tasks: "stylus"
      coffee:
        files: "src/*.coffee"
        tasks: "browserify"
    htmlmin:
      build:
        files:
          "build/index.html": ".tmp/index.html"
    cssmin:
      build:
        files:
          "build/index.css": ".tmp/index.css"
    uglify:
      build:
        files:
          "build/vendor.js": ".tmp/vendor.js"
          "build/index.js": ".tmp/index.js"

  grunt.registerTask "server", [
    "clean:server"
    "jade"
    "browserify"
    "stylus"
    "express"
    "watch"
  ]

  grunt.registerTask "build", [
    "clean:build"
    "jade"
    "browserify"
    "stylus"
    "htmlmin"
    "cssmin"
    "uglify"
  ]

  grunt.registerTask "default", [
    "server"
  ]
