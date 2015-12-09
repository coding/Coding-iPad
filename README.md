#Coding-iPad客户端说明
## Just run it！
想要看看 iPad 版本什么样，没问题！ clone 或者下载代码后，初次执行时，双击根目录下的 **bootstrap** 脚本，该脚本会准备初始数据，完成后会打开工程，点击 Xcode 运行！So easy，妈妈再也不用担心我的代码编译出错了！（之后只需打开 CodingForiPad.xcworkspace 即可）

## 嗯……，你的代码好像很棒，请告诉我xx是怎么做的
先告诉大家代码大概在哪里。

	.
	├── CodingForiPad
	│   ├── Vendor：因为各种原因没有用Pods管理的第三方库
	│   ├── Resources：资源文件
	│   ├── Util：一些工具类，Category等
	│   ├── Request：网络请求
	│   ├── Models：数据模型，一般一个网络请求会对应一个model
	│   ├── RequestExt：请求的业务扩展，用于分离基本请求以便于复用代码
	│   ├── ModelsExt：数据模型的业务扩展，用于分离基本模型以便于代码复用
	│   ├── Manager：一些单例
	│   │   ├── AddressManager：iPhone版本代码
	│   │   ├── Coding_FileManager：文件上传（iPhone版本代码）
	│   │   ├── COSession：登录用户管理
	│   │   ├── COUnReadCountManager：读信息、私信管理
	│   │   ├── ImageSizeManager：iPhone版本代码
	│   │   ├── JobManager：iPhone版本代码
	│   │   ├── StartImagesManager：iPhone版本代码
	│   │   ├── TagsManager：iPhone版本代码
	│   │   └── WebContentManager：格式化为网页使用，iPhone版本代码 
	│   └── ViewController
	│       ├── Style：基本样式，颜色等
	│       ├── Custom：一些自定义的View
	│       ├── Base：基本Controller
	│       ├── User：用户资料相关的UI
	│       ├── Project：项目相关的UI
	│       ├── Task：任务相关的UI
	│       ├── Tweet：冒泡相关的UI
	│       ├── Message：消息和私信相关的UI
	│       └── Setting：设置相关的UI
	└── Pods：项目使用了[CocoaPods](http://code4app.com/article/cocoapods-install-usage)这个类库管理工具
    
有两个比较隐蔽的问题，需要说明一下。首先，Coding 上部分资源是WebP格式，使用 SDWebImage 时，需要加入 WebP.framework；另外，在 Coding 的一些图片需要验证 Cookie 的，所以，在使用 SDWebImage 时，注意启用 Cookie，增加 SDWebImageHandleCookies 选项，代码如下所示：

	[self.regCodeImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.regCodeImageView.image = [UIImage imageNamed:@"captcha_loadfail"];
            });
        }
    }];
    
iPad 客户端使用了 Storyboard，所以在代码阅读上，建议先从 Storyboard 开始，了解整个项目的脉络（由于项目比较大，打开 Storyboard 项目的速度取决于机器的配置，Orz）。另外从 UI 来入手也比较直观，在 Storyboard 中也可以直接看到 UI 对应的 Controllor。

关于 ViewControllerr目录的组织基本是按照 UI 上展现来组织的，比如 Tweet 目录，主要是存放冒泡相关实现的代码，而其所对应的网络请求和 Models 也都是 COTweet 开头，这样大家很容易提纲挈领从一点贯通全面。

RequestExt 和 ModelsExt 目录下是与业务比较相关的请求和模型，这样做是为了使数据请求和模型与业务逻辑无关，保证这部分代码能够复用。

## 很好，我也要写一个这么棒的Coding客户端
没问题，现在来告诉大家，怎么复用代码。

不过，略微有点遗憾，由于项目比较紧张，当前只有网络请求和 Model 可以轻松复用。

首先，再讲一个隐蔽的问题，关于用户登录！Coding 的用户验证是通过 Cookie 来验证的，所以问题来了，如果你直接调用登录接口，会发现登录成功了，但是访问其他接口会提示用户未登录，为什么呢，因为 Cookie 没有存储，为什么没有存储，因为你在登录之前没有请求验证码接口。所以，再你调用登录接口之前，**必须先请求验证码接口！！！必须先请求验证码接口！！！必须先请求验证码接口！！！**（重要的事情说三遍）

### 网络请求
网络请求时基于 AFNetworking 的，稍微封装了一下，所有接口请求都是继承于 CODataRequest。 Coding 是 RestFul 接口，HTTP 请求除了GET、POST，之外还有 PUT 和 DELETE 方法，所以在 CODataRequest 实现了上述四种基本请求方法。一个接口可能既支持 GET，也支持 DELETE，所需要的参数不尽相同。因此，我定义了几个指示说明性的宏来标识请求和参数，如下所示：

	#define COQueryParameters		// Get 参数
	#define COUriParameters        // URI 参数
	#define COFormParameters       // Post 参数

	#define COGetRequest    /** Get请求 */
	#define COPostRequest   /** Post请求 */
	#define COPutRequest    /** Pust请求 */
	#define CODeleteRequest /** Delete请求 */

以用户登录接口为例：

	COPostRequest
	@interface COAccountLoginRequest : CODataRequest
	
	@property (nonatomic, copy) COFormParameters NSString *email;
	@property (nonatomic, copy) COFormParameters NSString *password;
	@property (nonatomic, copy) COFormParameters NSString *jCaptcha;
	@property (nonatomic, copy) COFormParameters NSString *rememberMe;
	
	@end
	
COPostRequest 表示这个接口是 POST 接口，调用的时候需要执行 postWithSuccess 方法；

COFormParameters 表示参数是 Post 使用的参数；

####请求实现
CODataRequest 将一个请求分为了四个阶段，请求准备，参数填充，完成准备，发起请求，数据解析。如果需要实现一个新请求，正常来说，需要完成请求准备和参数填充两个阶段，一般来说在准备阶段我们主要设置请求的 path，代码如下所示：

	- (void)prepareForRequest
	{
	    self.path = @"/login";
	}

参数准备主要是建立参数映射字典，将请求的参数映射为对应的接口参数，代码如下：

	- (NSDictionary *)parametersMap
	{
	    return @{
	             @"email" : @"email",
	             @"password" : @"password",
	             @"rememberMe" : @"remember_me",
	             @"jCaptcha" : @"j_captcha",
	             };
	}
	
其中 key 是请求的属性，对应的 value 是接口的参数名。


数据解析阶段是将接口返回的 JSON 封装为 CODataResponse 对象，并将数据映射成对应的 Model，代码如下：

	- (CODataResponse *)postResponseParser:(id)response
	{
	    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypeDefault];
	}
	
还有一个完成准备的阶段，这是表示，参数准备就绪，可以开始了，这时，我们可能还需要做一些事情，比如我封装了一个 COPageRequest，所有分页请求的数据都继承于它，让我们看看，它是怎么做的：

	- (void)readyForRequest
	{
	    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
	    [params setObject:@(self.page) forKey:@"page"];
	    [params setObject:@(self.pageSize) forKey:@"pageSize"];
	    self.params = [NSDictionary dictionaryWithDictionary:params];
	}
	
COPageRequest 使用了 readyForRequest，将 page 和 pageSize 两个参数追加到参数映射中，这样其他的分页请求就不需要在参数映射中写这两个参数了。

### 数据模型

数据模型采用了[Mantle](https://github.com/Mantle/Mantle)将 JSON 映射为对象。来看一个简单的列子：

	@interface COFileCount : MTLModel<MTLJSONSerializing>

	@property (nonatomic, assign) NSInteger folderId;
	@property (nonatomic, assign) NSInteger count;
	
	@end

	@implementation COFileCount

	+ (NSDictionary *)JSONKeyPathsByPropertyKey
	{
	    return @{@"folderId" : @"folder",
	             @"count" : @"count",
	             };
	}
	
	@end
	
是不是有些熟悉？没错，网络请求也参考了 Mantle 的实现。同样的 JSONKeyPathsByPropertyKey 中，key 对应的是 Model 的属性，value 对应的是 JSON 中的数据名。

复杂模型的建立，请详细参考 Mantle 的文档。

### 请求与模型的桥梁

CODataResponse 是请求于模型之间的桥梁。CODataResponse 封装了整个网络请求返回数据，包含了code、msg、error以及数据等。所以，一个网络请求返回后，我们需要先检查 CODataResponse 中的 code，如果 code 为0，则表示请求 OK，然后还需要判断 error，这个 error主要是我们解析数据时产生的错误，多数是模型建立的不对，或者接口模型调整导致的。

因为 Coding 的接口返回比较规范，主要是三种形式，字典，列表和 Pageable，因此 CODataResponse 封装了这三种形式的数据解析，解析数据变的非常简单，代码如下所示：

	- (CODataResponse *)postResponseParser:(id)response
	{
	    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypeDefault];
	}
	
这是用户登录接口的数据解析，是不是很容易？

### 代码使用
拷贝 Request 和 Model 目录到你的项目中，在 Podfile 中添加如下两行：

	pod 'AFNetworking'
	pod 'Mantle'
	
代码复用从未如此轻松……

# 好了，扬帆起航
你可以专注于 UI 和交互了，去写一个牛闪闪的 Coding 客户端吧！

#License
[MIT](License)
