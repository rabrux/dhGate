(function() {
  var colors, config, ecoPath, ecosystem, entry, f, file, files, fs, fullpath, i, index, j, k, len, len1, len2, modules, p, path, task, taskClientPath, taskClientPotentialsPath, taskName, tasks;

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

  ecosystem = {
    apps: []
  };

  console.log('->'.green, 'looking for hand added modules');

  modules = path.join(process.cwd(), config.root, 'modules');

  files = fs.readdirSync(modules);

  taskClientPotentialsPath = [path.join('node_modules', 'dhgate', 'dist', 'core', 'TaskClient.js'), path.join('dist', 'core', 'TaskClient.js')];

  taskClientPath = void 0;

  for (i = 0, len = taskClientPotentialsPath.length; i < len; i++) {
    p = taskClientPotentialsPath[i];
    if (fs.existsSync(p)) {
      taskClientPath = p;
      break;
    }
  }

  for (j = 0, len1 = files.length; j < len1; j++) {
    file = files[j];
    fullpath = path.join(modules, file);
    f = fs.lstatSync(fullpath);
    if (f.isDirectory()) {
      console.log('->'.green, 'load module', file.cyan);
      tasks = fs.readdirSync(fullpath);
      for (k = 0, len2 = tasks.length; k < len2; k++) {
        task = tasks[k];
        taskName = file + ':' + path.parse(task).name;
        task = {
          name: taskName,
          script: taskClientPath,
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
          ecosystem.apps.splice(index, 1, task);
        }
      }
    }
  }

  fs.writeFileSync(ecoPath, JSON.stringify(ecosystem, null, 2));

  console.log('->'.green, 'ecosystem updated with hand added modules');

}).call(this);
