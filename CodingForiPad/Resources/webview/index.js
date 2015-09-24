var express = require('express'),
    app = express(),
    app_port = process.env.VCAP_APP_PORT || 3000,
    exec = require('child_process').exec,
    bodyParser = require('body-parser'),
    child;

app.use(express.static(__dirname + '/app'));

app.use(bodyParser.urlencoded({
  extended: true
}));

app.use(bodyParser.json());

var update_history = [],
    WEBHOOK_TOKEN = process.env.WEBHOOK_TOKEN || 123456,
    DOWNLOAD_PATH = process.env.DOWNLOAD_PATH || null,
    NO_TOKEN_MSG = '密码密码！没有密码你看什么看，加上正确的 token 参数再来好么~',
    DOWNLOD_URL_REGEXP = new RegExp('https://coding.net/u/(.+)/p/(.+)/git'),
    COMMANDS = {
        'curl': 'curl -o update.zip {DOWNLOAD_PATH}',
        'rm_exists': 'rm -rf .tmp',
        'mkdir': 'mkdir .tmp',
        'unzip': 'unzip update.zip -d .tmp/',
        'cp': 'cp -r ./.tmp/app/* app/',
        'rm': 'rm -rf .tmp update.zip'
    };

var execCmd = function(cmd, callback){
    console.log('Executing command: ', cmd);
    return child = exec(cmd,function (error, stdout, stderr) {
        console.error('stdout: ' + stdout);
        console.error('stderr: ' + stderr);
        if (error !== null) {
          console.error('exec error: ' + error);
        }
        callback(error);
    });
};

var execCmdStack = function(cmds, callback){
    var cmd = cmds.shift();
    if(cmd){
        if(typeof cmd === 'function'){
            cmd();
        }else{
            execCmd(cmd, function(error){
                if(!error){
                    execCmdStack(cmds, callback);
                }
                if(cmds.length === 0){
                    callback && callback(error);
                }
            });
        }
    }else{
        callback && callback();
    }
};

var update = function(url){

    var download_url = url || 'https://coding.net/u/bluishoul/p/static-web/git/archive/master';
    var download_command = COMMANDS.curl.replace('{DOWNLOAD_PATH}', download_url);

    var cmds = [
        download_command,
        COMMANDS.rm_exists,
        COMMANDS.mkdir,
        COMMANDS.unzip,
        COMMANDS.cp,
        COMMANDS.rm
    ];

    execCmdStack(cmds, function(error){
        var history = {
            type: 'update',
            updated_at: new Date().getTime()
        }
        history.status = error ? 'error' : 'success';
        update_history.push(history);
    });

};

var generateHistory = function(req){
    var params = ['after', 'before', 'commits', 'ref', 'master', 'token', 'short_message'];
    var history = {};
    for(var i in params){
        var param = params[i];
        var value = req.param(param || '');
        if(param && value){
            history[param] = value;
        }
    }
    history.type = 'webhook';
    history.updated_at = new Date().getTime();
    return history;
};

var saveIntoHistotry = function(req){
    var token = req.param('token');
    console.log('TOKEN:', token);
    console.log('REPO:', req.param('repository'));
    console.log('PARAMS:', req.params, req.body, req.query);
    if(token == WEBHOOK_TOKEN){
        var history = generateHistory(req);
        update_history.push(history);
        return true;
    }
    return false;
};

var exactDownloadUrl = function(req){
    var repo = req.param('repository'),
        ref = req.param('ref') || 'master';
    var url = repo ? repo.url : '';
    console.log(repo);
    if(url){
        var arr = url.match(DOWNLOD_URL_REGEXP);
        if(arr && arr.length == 3){
            var u = arr[1],
                p = arr[2];
            return ['https://coding.net/u/', u, '/p/', p, '/git/archive/', ref].join('');
        }
    }
    return DOWNLOAD_PATH || null;
};

app.post('/coding-services/update', function(req, res){
    var output = saveIntoHistotry(req);
    if(output){
        var url = exactDownloadUrl(req);
        update(url);
        res.set({'Content-Type': 'text/json;charset=utf-8'});
        res.send(update_history);
    }else{
        res.set({'Content-Type': 'text/plain;charset=utf-8'});
        res.send(NO_TOKEN_MSG);
    }
    res.end();
});

app.get('/coding-services/history', function(req, res){
    var token = req.param('token');
    if(token == WEBHOOK_TOKEN){
        res.set({'Content-Type': 'text/json;charset=utf-8'});
        res.send(update_history);
    }else{
        res.set({'Content-Type': 'text/plain;charset=utf-8'});
        res.send(NO_TOKEN_MSG);
    }
    res.end();
});

var server = app.listen(app_port, function(req, res){
  console.log('Listening on port %d', server.address().port);
});
