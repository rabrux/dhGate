gulp   = require 'gulp'
coffee = require 'gulp-coffee'
watch  = require 'gulp-watch'

config = require './.dhgate.json'

source = [
  config.root + '/*.coffee'
  config.root + '/**/*.coffee'
]

# build task
gulp.task 'build', ->
  gulp
    .src source
    .pipe coffee().on( 'error', ( err ) ->
      console.log err.message
      @emit 'end'
    )
    .pipe gulp.dest config.dist
  return

# watch on dev
gulp.task 'watch', ->
  gulp.watch source, [ 'build' ]

# dev task
gulp.task 'dev', [
  'build'
  'watch'
]

gulp.task 'default', [ 'build' ]
