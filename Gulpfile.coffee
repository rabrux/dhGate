gulp   = require 'gulp'
coffee = require 'gulp-coffee'
watch  = require 'gulp-watch'
mocha  = require 'gulp-mocha'
gutil  = require 'gulp-util'

resources =
  code :
    src : [
      'src/*.coffee'
      'src/**/*.coffee'
    ]
    dest : 'dist'
  tests :
    src : [
      'test/src/*.coffee'
      'test/src/**/*.coffee'
    ]
    dest : 'test/dist'

# build source code
gulp.task 'build:code', ->
  gulp
    .src resources.code.src
    .pipe coffee( bare : true ).on( 'error', ( err ) ->
      console.log err.message
      @emit 'end'
    )
    .pipe gulp.dest resources.code.dest

# build test
gulp.task 'build:tests', ->
  gulp
    .src resources.tests.src
    .pipe coffee( bare : true ).on( 'error', ( err ) ->
      console.log err.message
      @emit 'end'
    )
    .pipe gulp.dest resources.tests.dest

# build all
gulp.task 'build', [
  'build:code'
  'build:tests'
]

###
## mocha test tasks
####

runMocha = ->
  gulp
    .src 'test/dist/*.js', { read : false }
    .pipe mocha
      timeout  : 10000
      reporter : 'list'
    .on 'error', gutil.log

gulp.task 'run:tests', ->
  runMocha()

# watch on dev
gulp.task 'watch', ->
  gulp.watch resources.code.src, [ 'build:code', 'run:tests' ]
  gulp.watch resources.tests.src, [ 'build:tests', 'run:tests' ]

# dev task
gulp.task 'dev', [
  'build'
  'watch'
]

gulp.task 'default', [ 'build' ]
