# dhGate
Dark Hole Gateway for PM2 and socket.io

## install dhGate
`$ npm install dhgate`

## cli

`$ dhgate --help`

```
  Usage: dhgate [options] [command]
  
  Commands:
  
    help    Display help
    init    Initialize dhGate project
    task    Creates new task file
    update  After reinitialize project, it rebuilds ecosystem file
  
  Options:
  
    -h, --help     Output usage information
    -v, --version  Output the version number
  
  Examples:
  
    - initializes new project on directory "source" and listen port "1234"

    $ dhgate init --src source --dist bundle --port 1234

    - creates task file on root app directory with timeout equals to 2 minutes, if root directory is "app" the result wound be a file on path "app/auth/login.coffee"

    $ dhgate task --name auth:login --timeout 2
```

### init

`$ dhgate init --help`

```
  Usage: dhgate init [options] [command]
  
  Commands:
  
    help  Display help
  
  Options:
  
    -d, --dist [value]  app production directory (defaults to "dist")
    -h, --help          Output usage information
    -p, --port <n>      app listen port (defaults to 1337)
    -s, --src [value]   app source directory (defaults to "src")
    -v, --version       Output the version number
  
  Examples:
  
    - initializes new project on directory "source" and listen port "1234"

    $ dhgate init --src source --dist bundle --port 1234
```

### task

`$ dhgate task --help`

```
  Usage: dhgate task [options] [command]
  
  Commands:
  
    help  Display help
  
  Options:
  
    -h, --help         Output usage information
    -n, --name         Task name in format <module>:<task>
    -t, --timeout <n>  Task timeout (defaults to 10)
    -v, --version      Output the version number
  
  Examples:
  
    - creates task file on root app directory with timeout equals to 2 minutes, if root directory is "app" the result wound be a file on path "app/auth/login.coffee"

    $ dhgate task --name auth:login --timeout 2
```

### update

`$ dhgate update --help`

it updates ecosystem pm2 config file to load all modules in `<src>/modules`


