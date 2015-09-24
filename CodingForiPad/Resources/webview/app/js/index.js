$(function(){
    var $webview_detail = $('.webview-detail');
    var html = $webview_detail.html();
    $webview_detail.html(API.restyleEmoji(html));
    API.highlight($webview_detail);
});
