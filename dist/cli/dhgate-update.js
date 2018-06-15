var colors, config, ecoPath, ecosystem, entry, f, file, files, fs, fullpath, i, index, j, len, len1, modules, path, task, taskName, tasks;

path = require('path');

fs = require('fs');

colors = require('colors');

try {
  config = require(path.join(process.cwd(), '.dhgate.json'));
} catch (error) {
  console.log("\n  Application is not initialized yet, please run init command before create task.".red);
  process.exit(2);
}

ecoPath = path.join(process.cwd(), 'ecosystem.json');

try {
  ecosystem = require(ecoPath);
} catch (error) {
  ecosystem = {
    apps: []
  };
}

console.log('->'.green, 'looking for hand added modules');

modules = path.join(process.cwd(), config.root, 'modules');

files = fs.readdirSync(modules);

for (i = 0, len = files.length; i < len; i++) {
  file = files[i];
  fullpath = path.join(modules, file);
  f = fs.lstatSync(fullpath);
  if (f.isDirectory()) {
    console.log('->'.green, 'load module', file.cyan);
    tasks = fs.readdirSync(fullpath);
    for (j = 0, len1 = tasks.length; j < len1; j++) {
      task = tasks[j];
      taskName = file + ':' + path.parse(task).name;
      task = {
        name: taskName,
        script: path.join(config.dist, 'client.js'),
        merge_logs: true,
        autorestart: false,
        watch: true,
        env: {
          APP_NAME: taskName,
          APP_ROOT: path.join(config.dist, 'modules'),
          APP_PORT: config.port,
          APP_TIMEOUT: 2
        }
      };
      entry = ecosystem.apps.filter(function(el) {
        return el.name === taskName;
      }).shift();
      if (!entry) {
        ecosystem.apps.push(task);
        console.log("\t->".green, 'task', taskName.cyan, 'added to ecosystem pm2 config file');
      } else {
        index = ecosystem.apps.indexOf(entry);
        task.env.APP_TIMEOUT = ecosystem.apps[index].env.APP_TIMEOUT;
        ecosystem.apps.splice(index, 1, task);
        console.log("\t->".green, 'task', taskName.cyan, 'updated on ecosystem pm2 config file');
      }
    }
  }
}

fs.writeFileSync(ecoPath, JSON.stringify(ecosystem, null, 2));

console.log('->'.green, 'ecosystem updated with hand added modules');
