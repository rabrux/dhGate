var args, assetsPotentialPaths, colors, config, ecoPath, ecosystem, entry, flags, fs, i, index, len, module, modulePath, p, parts, path, shell, task, taskPath;

args = require('args');

path = require('path');

fs = require('fs');

colors = require('colors');

shell = require('shelljs');

try {
  config = require(path.join(process.cwd(), '.dhgate.json'));
} catch (error) {
  console.log("\n  Application is not initialized yet, please run init command before create task.".red);
  process.exit(2);
}

args.option('name', 'Task name in format <module>:<task>', void 0).option('timeout', 'Task timeout', 10).example('dhgate task --name auth:login --timeout 2', 'creates task file on root app directory with timeout equals to 2 minutes, if root directory is "app" the result wound be a file on path "app/auth/login.coffee"');

flags = args.parse(process.argv);

if (!flags.name) {
  console.log("\n  option --name can not be empty".red);
  args.showHelp();
  process.exit(2);
}

if (flags.name.split(':').length !== 2) {
  console.log("\n  task name needs to be formated like <module>:<task> see example in help".red);
  args.showHelp();
  process.exit(2);
}

parts = flags.name.split(':');

module = parts.shift();

modulePath = path.join(process.cwd(), config.root, 'modules', module);

if (!fs.existsSync(modulePath)) {
  fs.mkdirSync(modulePath);
  console.log('->'.green, 'module', module.cyan, 'created.');
}

task = parts.shift();

taskPath = path.join(modulePath, task + '.coffee');

assetsPotentialPaths = [path.join(process.cwd(), 'node_modules', 'dhgate', 'assets'), path.join(process.cwd(), 'assets')];

for (i = 0, len = assetsPotentialPaths.length; i < len; i++) {
  p = assetsPotentialPaths[i];
  if (fs.existsSync(p)) {
    shell.cp(path.join(p, 'task.coffee'), taskPath);
    break;
  }
}

console.log('->'.green, 'task', task.cyan, 'created for module', module.cyan);

ecoPath = path.join(process.cwd(), 'ecosystem.json');

try {
  ecosystem = require(ecoPath);
} catch (error) {
  ecosystem = {
    apps: []
  };
}

task = {
  name: flags.name,
  script: path.join(config.dist, 'client.js'),
  merge_logs: true,
  autorestart: false,
  watch: true,
  env: {
    APP_NAME: flags.name,
    APP_ROOT: path.join(config.dist, 'modules'),
    APP_PORT: config.port,
    APP_TIMEOUT: flags.timeout
  }
};

entry = ecosystem.apps.filter(function(el) {
  return el.name === flags.name;
}).shift();

if (!entry) {
  ecosystem.apps.push(task);
} else {
  index = ecosystem.apps.indexOf(entry);
  ecosystem.apps.splice(index, 1, task);
}

fs.writeFileSync(ecoPath, JSON.stringify(ecosystem, null, 2));

console.log('->'.green, 'task', flags.name.cyan, 'added to ecosystem pm2 config file');
