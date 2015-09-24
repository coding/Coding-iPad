var getLanguage = function (html, language) {
	var lang = (hljs.getLanguage(language) ? language : 'java');
	var lcode = void 0;
	if (!lang || lang.length === 0) {
		lcode = hljs.highlightAuto(html);
	}
	lang = lang || lcode.language || 'java';
	return lang;
};

var buildCodeBlock = function (meta_code, language) {
	var code_lines = meta_code.split('\n');
	var lang = getLanguage(meta_code, language);
	var lhtml = [],
		chtml = [];
	$.each(code_lines, function (i, line) {
		var rline = hljs.highlight(lang, line, true, top);
		var top = rline.top;
		var code = rline.value;
		var k = i + 1;
		lhtml.push('<span class="num" id="L' + k + '" rel="#L' + k + '" num="' + k + '">' + k + '</span>');
		chtml.push('<div class="line" id="CL' + k + '">' + code + '</div>');
	});
	ohtml = [];
	ohtml.push('<table class="blob-code-view blob-code-diff">');
	ohtml.push('<tbody><tr class="blob-line">');
	ohtml.push('<td class="blob-nums">');
	ohtml.push(lhtml.join(''));
	ohtml.push('</td><td class="blob-code">');
	ohtml.push('<div class="blob-code-body"><div class="blob-body highlight"><pre>');
	ohtml.push(chtml.join(''));
	ohtml.push('</pre></div></div>');
	ohtml.push('</td></tr>');
	ohtml.push('</tbody>');
	ohtml.push('</table>');
	return ohtml.join('\n');
};

$(function () {
	var code = $('#code-placeholder');
	var file = {
		data: code.html(),
		lang: '${file_lang}'
	};
	file.data = file.data.
		replace(/&amp;/gm, '&').
		replace(/&lt;/gm, '<').
		replace(/&gt;/gm, '>');
	var html = buildCodeBlock(file.data, file.lang);
	$('#code-view').html(html);
});
