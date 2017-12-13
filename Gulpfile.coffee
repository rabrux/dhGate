gulp   = require 'gulp'
coffee = require 'gulp-coffee'
watch  = require 'gulp-watch'

config = require './conf/gulp.json'

# Compile CoffeeScript
gulp.task 'build', ->
  conf = config.coffee
  gulp
    .src conf.source
    .pipe coffee().on( 'error', ( err ) ->
      console.log err.message
      @emit 'end'
    )
    .pipe gulp.dest conf.dest
  return

gulp.task 'watch', ->
  gulp.watch config.coffee.source, [ 'build' ]

gulp.task 'dev', [
  'build'
  'watch'
]

gulp.task 'default', [ 'build' ]