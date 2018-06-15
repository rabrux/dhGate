{ TaskClient } = require 'dhgate'

if not process.env.APP_PORT or not process.env.APP_ROOT or not process.env.APP_NAME or not process.env.APP_TIMEOUT
  throw Error 'missing environment variables'

mod = new TaskClient
  uri     : 'http://localhost:' + process.env.APP_PORT
  modules : process.env.APP_ROOT
  task    : process.env.APP_NAME
  timeout : process.env.APP_TIMEOUT

