var highlightWithLineNumber = (function () {

	var defaults, getLang, highlightBlobLines, htmlDecode, htmlEncode, initHighLight, link, preLine;
	defaults = {
		lang: 'java',
		anchor: true
	};
	preLine = -1;
	htmlEncode = function (str) {
		var div;
		div = document.createElement("div");
		div.appendChild(document.createTextNode(str));
		return div.innerHTML;
	};
	htmlDecode = function (str) {
		var div;
		div = document.createElement("div");
		div.innerHTML = str;
		return div.innerHTML;
	};
	getLang = function (html, language) {
		var lang, lcode;
		lang = (hljs.getLanguage(language) ? language : defaults.lang);
		lcode = void 0;
		if (!lang || lang.length === 0) {
			lcode = hljs.highlightAuto(html);
		}
		lang = lang || lcode.language || defaults.lang;
		return lang;
	};
	initHighLight = function () {
		var codeLine, first_line, last_line, matches, max, min;
		if (window.location.hash !== '') {
			matches = window.location.hash.match(/\#L(\d+)(?:\-L?(\d+))?/);
			first_line = parseInt((matches != null ? matches[1] : void 0));
			last_line = parseInt((matches != null ? matches[2] : void 0));
			if (!isNaN(first_line)) {
				if (isNaN(last_line)) {
					last_line = first_line;
				}
				max = Math.max(last_line, first_line);
				min = Math.min(last_line, first_line);
				while (min <= max) {
					codeLine = $('#CL' + min);
					codeLine.css({
						'background-color': 'rgb(255, 255, 204)'
					});
					min++;
				}
			}
		}
	};
	highlightBlobLines = function (options) {
		return options.find('span.num').on('click', function () {
			var codeLine, end, id, max, min, num, start;
			num = $(this);
			id = num.attr('num');
			codeLine = $('#CL' + id);
			$('.line').css({
				'background-color': 'rgb(255, 255, 255)'
			});
			if (preLine < 0) {
				preLine = id;
			}
			if (event.shiftKey) {
				if (preLine > 0) {
					start = 0;
					end = 0;
					min = start = Math.min(preLine, id);
					max = end = Math.max(preLine, id);
					while (start <= end) {
						$('#CL' + start).css({
							'background-color': 'rgb(255, 255, 204)'
						});
						start++;
					}
					$location.hash('L' + min + '-L' + max);
					location.skipReload().path($location.$$path);
					preLine = Math.min(id, preLine);
				}
			} else {
				$location.hash('L' + id);
				location.skipReload().path($location.$$path);
				codeLine.css({
					'background-color': 'rgb(255, 255, 204)'
				});
				preLine = id;
			}
		});
	};

	var link = function (code_str, language, element) {
		var chtml, html, html_dom, lhtml, lines, ohtml, top;
		top = null;
		//replace &lt; and &gt; back
		code_str = code_str.
			replace(/&amp;/g, '&').
			replace(/&lt;/g, '<').
			replace(/&gt;/g, '>');;
		html_dom = $("<code class=\"" + language + "\">" + (htmlEncode(code_str)) + "</code>");
		hljs.highlightBlock(html_dom[0]);
		html = html_dom.html();
		lines = html.split('\n');
		lhtml = [];
		chtml = [];
		lines.forEach(function (v, i) {
			var k;
			k = i + 1;
			lhtml.push('<span class="num" id="L' + k + '" rel="#L' + k + '" num="' + k + '">' + k + '</span>');
			chtml.push('<div class="line" id="CL' + k + '">' + v + '</div>');
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
		element.html(ohtml.join(''));
		initHighLight();
		highlightBlobLines(element);
	};

	return link;

})();

$(function () {
	var code = $('#code-placeholder');
	var file = {
		data: code.html(),
		lang: 'c'
	};
	highlightWithLineNumber(file.data, file.lang, $('#code-view'));
});
