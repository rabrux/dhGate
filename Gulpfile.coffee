gulp   = require 'gulp'
coffee = require 'gulp-coffee'
watch  = require 'gulp-watch'

# build task
gulp.task 'build', ->
  gulp
    .src [ 'src/*.coffee', 'src/**/*.coffee' ]
    .pipe coffee().on( 'error', ( err ) ->
      console.log err.message
      @emit 'end'
    )
    .pipe gulp.dest 'dist'
  return

# watch on dev
gulp.task 'watch', ->
  gulp.watch [ 'src/*.coffee', 'src/**/*.coffee' ], [ 'build' ]

# dev task
gulp.task 'dev', [
  'build'
  'watch'
]

gulp.task 'default', [ 'build' ]