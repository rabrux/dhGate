(function() {
  var args, colors, flags, fs, gatePath, path;

  args = require('args');

  path = require('path');

  fs = require('fs');

  colors = require('colors');

  args.option('src', 'app source directory', 'src').option('dist', 'app production directory', 'dist').option('port', 'app listen port', 1337).example('dhgate init --src source --dist bundle --port 1234', 'initializes new project on directory \"source\" and listen port \"1234\"');

  flags = args.parse(process.argv);

  if (!fs.existsSync(flags.src)) {
    fs.mkdirSync(flags.src);
  }

  console.log('->'.green, 'application directory created at', flags.src.cyan);

  fs.writeFileSync('.dhgate.json', JSON.stringify({
    root: flags.src,
    dist: flags.dist,
    port: flags.port
  }, null, 2));

  console.log('->'.green, 'configuration file created as', '.dhgate.json'.cyan);

  gatePath = path.join(process.cwd(), flags.src, 'gate.coffee');

  fs.createReadStream(path.join(process.cwd(), 'node_modules', 'dhgate', 'assets', 'gate.coffee')).pipe(fs.createWriteStream(gatePath));

  console.log('->'.green, 'gate index file created at', flags.src.cyan);

  fs.createReadStream(path.join(process.cwd(), 'node_modules', 'dhgate', 'assets', 'Gulpfile.coffee')).pipe(fs.createWriteStream(path.join(process.cwd(), 'Gulpfile.coffee')));

  console.log('->'.green, 'gulpfile created, use "gulp" command to compile your app and "gulp dev" to watch and recompile');

}).call(this);
