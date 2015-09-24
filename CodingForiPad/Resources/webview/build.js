var inline = require('inline-html'),
    path = require('path'),
    fs = require('fs');

var args = process.argv || [],
    source_name = 'bubble.html',
    target_name = 'bubble.html';

var args2 = args[2],
    args3 = args[3],
    args4 = args[4];

var with_tpl_content = false,
    iterate_src = false;

if (args.length <= 2) {
    throw new Error('args error!');
}

//node build.js -t
if (args2 === '-t') {
    target_name = 'bubble-demo.html'
    with_tpl_content = true;
}else if(args2 === '-a'){
    iterate_src = true;
}

//node build.js xxx
if (args2 !== '-t' && args !== '-a') {
    source_name = args2 + '.html';
    target_name = args2 + '.html';

    //node build.js xxx.html yyy.html
    if (args3 && args3 === '-t') {
        target_name = args2 + '-demo.html';
        with_tpl_content = true;
    }

}


var generateHtml = function(source_name, target_name, with_tpl_content){
    source_name = 'app/src/' + source_name;
    target_name = 'app/build/' + target_name;
    console.log('[Generating]', source_name, ' -> ', target_name, with_tpl_content ? '(demo)' : '');
    inline(path.join(__dirname, source_name), function (html) {
        if (with_tpl_content) {
            //var tpl = fs.readFileSync(path.join(__dirname, 'template.tpl'), {encoding: 'utf-8'})
            var tpl = fs.readFileSync(path.join(__dirname, 'markdown.html'), {encoding: 'utf-8'})
            html = html.replace(/\$\{webview\_content\}/ig, tpl);
        }
        fs.writeFileSync(path.join(__dirname, target_name), html)
        console.log('[Generated]', source_name, ' -> ', target_name, with_tpl_content ? '(demo)' : '');
    });
}

if(iterate_src){
    var sources =  fs.readdirSync('app/src');
    for(var i in sources){
        var file = sources[i];
        var name = file.substring(0, file.indexOf('.'));
        source_name = name + '.html';
        target_name = name + '.html';
        var demo_name = name + '-demo.html';
        generateHtml(source_name, target_name);
        generateHtml(source_name, demo_name, true);
    }
}else{
    generateHtml(source_name, target_name, with_tpl_content);
}

