var API = (function(window, $, hljs,undefined){

    var highlight = function(el){
        $(el).find('pre code').each(function(i, block) {
            hljs.highlightBlock(block);
        });
    };

    var restyleEmoji = function(){

        var replaceMonkeyToText = function(ctn){
            var monkey = ctn.find('.emotion.monkey');
            if(monkey.length === 0) return ctn;
            monkey.each(function(){
                var title = $(this).attr('title'),
                    url = $(this).attr('src');
                $(this).replaceWith([':', title , '@', url, ': '].join(''));
            });
            return ctn;
        };

        var splitMonkey = function(text){
            var reg = /(\:\S+\@\S+\:)/g;
            var monkey = text.split(reg);
            if(monkey.length === 1){
                return monkey;
            }
            //remove empty
            var new_monkey = [];
            $.each(monkey, function(i, m){
                if($.trim(m).length !== 0){
                    new_monkey.push(m);
                }
            });
            monkey = new_monkey;

            new_monkey = [];
            var continual_monkey = [];
            for(var i=0; i<monkey.length; i++){
                var m = monkey[i];
                if(m.match(reg)){
                    continual_monkey.push(m);
                }else{
                    if(continual_monkey.length > 0){
                        new_monkey.push(continual_monkey);
                        continual_monkey = [];
                    }
                    new_monkey.push(m);
                }
            }
            if(continual_monkey.length > 0){
                new_monkey.push(continual_monkey);
            }
            return new_monkey;
        };

        var textToImage = function(text){
            text = text.substring(1, text.length - 1);
            var params = text.split('@');
            var title = params[0],
                url = params[1];
            var img = $('<img>').attr('title', title).attr('src', url).addClass('emotion monkey');
            return img;
        };

        //monkey 数组 ---> html
        var continualMonkeyHandler = function(arr){
            var handlers = {
                1: function(images){
                    return $('<div class="one_wrapper"></div>').wrapInner(images)
                },
                2: function(images){
                    return handlers['1'](images);
                },
                3: function(images){
                    return $('<div class="three_wrapper"></div>').wrapInner(images)
                },
                more: function(images){
                    return handlers['3'](images);
                }
            };
            var images = $.map(arr, function(text){
                return textToImage(text);
            });
            var handler = handlers[arr.length];
            var result = handler && handler(images) || handlers.more(images);
            return  $('<div>').html(result);
        };

        var replaceMonkeyToImage = function(monkey){
            var html = '';
            $.each(monkey, function(i, m){
                if($.isArray(m)){
                    html += continualMonkeyHandler(m).html();
                }else{
                    html += m;
                }
            });
            return html;
        };

        return function (ctn) {
            var content = $('<div>').html(ctn);
            if(content.text() == ctn){
                return ctn
            }
            replaceMonkeyToText(content);
            var monkey = splitMonkey(content.html());
            var new_ctn = replaceMonkeyToImage(monkey);
            return new_ctn;
        };

    };

    return {
        highlight: highlight,
        restyleEmoji: restyleEmoji()
    };

})(window, jQuery, hljs);