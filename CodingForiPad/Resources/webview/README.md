#Usage

iOS / Android  开发的小伙伴们，下面说明如何使用各种 APP 中的 ```webview``` 模板。 

##Bubble

1. 请把 ```build``` 目录 中的 ```bubble.html``` 下载下来，放入你的工程中

2. 将 ```bubble.html``` 的 ```${webview_content}``` 替换成冒泡 json 中的 ```content```

3. 将替换过后的 html 内容塞到 ```webview``` 中即可。

4. 完毕，请鼓掌！

##Topic

*注意,```build```目录中  

```topic-ios.html``` 为 ```iOS``` 的讨论模板  

```topic-android.html``` 为 ```Android``` 的讨论模板  

将 ``${webview_content}``` 替换成 json 中的 ```content```


##Code
> build/code.html 是为 “代码预览” 准备的模板

将 ```code.html``` 中的 ```${file_code}``` 替换为代码,对应数据[^1]中的 ```file.data```

将 ```code.html``` 中的 ```${file_lang}``` 替换为代码语言,对应数据中的 ```file.lang```


##Markdown
>build/markdown.html 是为 “代码预览” 中预览 ```lang``` 为 ```markdown``` 的文件准备的模板

将 ```markdown.html``` 中的 ```${webview_content}``` 替换为对应数据中的 ```file.preview```

*注意： ```file.lang``` 为 ```markdown```

[^1]: 数据来源于： /api/user/:username/project/:project_name/git/blob/:file_path 接口
