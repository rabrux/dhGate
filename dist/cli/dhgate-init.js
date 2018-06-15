var args, child, cmd, colors, configure, exec, execSync, flags, fs, packageFile, path, shell, stream;

args = require('args');

path = require('path');

fs = require('fs');

shell = require('shelljs');

colors = require('colors');

exec = require('child_process').spawn;

execSync = require('child_process').spawnSync;

stream = require('stream');

args.option('src', 'app source directory', 'src').option('dist', 'app production directory', 'dist').option('port', 'app listen port', 1337).example('dhgate init --src source --dist bundle --port 1234', 'initializes new project on directory \"source\" and listen port \"1234\"');

flags = args.parse(process.argv);

configure = function() {
  var assetsPotentialPaths, child, fullPath, i, j, k, len, len1, len2, p, srcPath;
  fullPath = path.join(flags.src, 'modules');
  if (!fs.existsSync(fullPath)) {
    shell.mkdir('-p', fullPath);
  }
  console.log('->'.green, 'application directory created at', flags.src.cyan);
  fs.writeFileSync('.dhgate.json', JSON.stringify({
    root: flags.src,
    dist: flags.dist,
    port: flags.port
  }, null, 2));
  console.log('->'.green, 'configuration file created as', '.dhgate.json'.cyan);
  srcPath = path.join(process.cwd(), flags.src);
  assetsPotentialPaths = [path.join(process.cwd(), 'node_modules', 'dhgate', 'assets'), path.join(process.cwd(), 'assets')];
  for (i = 0, len = assetsPotentialPaths.length; i < len; i++) {
    p = assetsPotentialPaths[i];
    if (fs.existsSync(p)) {
      shell.cp(path.join(p, 'gate.coffee'), srcPath);
      break;
    }
  }
  console.log('->'.green, 'gate index file created at', flags.src.cyan);
  for (j = 0, len1 = assetsPotentialPaths.length; j < len1; j++) {
    p = assetsPotentialPaths[j];
    if (fs.existsSync(p)) {
      shell.cp(path.join(p, 'client.coffee'), srcPath);
    }
  }
  console.log('->'.green, 'client index file created at', flags.src.cyan);
  for (k = 0, len2 = assetsPotentialPaths.length; k < len2; k++) {
    p = assetsPotentialPaths[k];
    if (fs.existsSync(p)) {
      shell.cp(path.join(p, 'Gulpfile.coffee'), process.cwd());
    }
  }
  console.log('->'.green, 'gulpfile created, use "gulp" command to compile your app and "gulp dev" to watch and recompile');
  console.log('->'.green, 'installing node dev dependencies');
  child = exec(cmd, ['install', '--save-dev', 'gulp', 'gulp-coffee', 'gulp-watch', 'coffeescript']);
  child.stderr.on('data', function(data) {
    var message;
    message = data.toString();
    if (!/npm|WARN|deprecated/g.test(message)) {
      return console.error('->'.yellow, message);
    }
  });
  return child.on('close', function(code) {
    return console.log('->'.green, 'dev dependencies installed');
  });
};

packageFile = path.join(process.cwd(), 'package.json');

cmd = /^win/.test(process.platform) ? 'npm.cmd' : 'npm';

if (!fs.existsSync(packageFile)) {
  child = exec(cmd, ['init'], {
    stdio: [0, 'pipe', 'pipe']
  });
  child.stdout.on('data', function(data) {
    return process.stdout.write(data.toString());
  });
  child.stderr.on('data', function(data) {
    return console.log('err', data.toString());
  });
  child.on('close', function(code) {
    return configure();
  });
} else {
  configure();
}
