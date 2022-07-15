# Toutiao

## :bookmark_tabs: 摘要

在移动互联网的高速发展的大背景下，视频化成为主流的表达方式，移动互联网的普及也为视频的高速发展提供了坚实的用户基础，将媒体咨询通过视频的方式传播将能更大地激活用户的潜在需求和赋能用户。资讯视频化已经是大势所趋。头条视频版是一个短视频社区，用户可以上传自己的作品，也可以浏览作品来获取资讯。 

## :construction: 系统架构图

![image.png](https://s2.loli.net/2022/07/15/fKV6nXtpW3MP2SY.png)

## :beginner: 实现技术概要

**项目使用到的第三方库：**

- AFNetworking (3.2.1)

- MJExtension (3.4.1)

- MJRefresh (3.7.5)

- Masonry (1.1.0)

- SDWebImage (4.0.0)

- ShortMediaCache (0.1.0)

-  YBImageBrowser（ 2.1.5）

-  SDWebImage（4.4.6）

- Toast

- SJVideoPlayer

- TZImagePickerController

### 主页短视频模块

头条app的根控制器为一个`UITabBarController`，其中包括主页、上传和我的三个`TabBar`，进入app的默认页面为主页。头条主页短视频模块采用上下滑动的方式切换视频源，在本项目中采用`UITableView`控件封装每个短视频作品，每个作品是一个`UITableViewCell`，每个`cell`都占满整个屏幕，由视频的封面作为背景图，作品中的视频采用`AVPlayer`进行播放，同时实现了进度条、长按倍速播放和全屏播放等功能。主页视图使用`Masonry`进行布局。视频使用第三方框架`ShortMediaManager`进行缓存，在当前作品数据即将加载到底部时进行预加载，优化了播放性能。

### 搜索页面模块

搜索页面通过主页的`UISearchBar`进入。搜索页面主要由两部分组成，页面上方是`UISearchBar`为用户提供搜索功能，下方则采用`UITableView`显示搜索得到的数据，其中`UITableViewCell`为自定义控件，并且一个`UITableViewCell`显示一个视频的相关数据。若登录状态有误或出现请求错误则通过`UIAlertView`提示。搜索视图主要通过`Masonry`进行布局，分页加载通过`MJRefresh`实现。通过选择`cell`可跳转进入相应的视频播放页，其中视频播放页复用了主页短视频模块中视频播放及相关功能的实现。

### 个人主页模块

模块主要实现了展示用户信息，并修改注册信息功能，对应着两个ViewController，TTUserInfoController，TTUpdateInfoController。通过在TTTabBarController下对应的navigation添加TTUserInfoController，然后在vc的viewDidAppear阶段进行判断登录状态，若没有登录则跳转至登录界面，反之展示个人主页。登录成功之后也跳转至个人主页。个人主页由UITableViewController构成，分为两个部分，一部分是个人信息，将他们封装到TTUserInfoView添加至tableView的headView部分，而表格的cell则由自定义的TTUserInfoCell构成。

### 用户登录模块+上方导航栏

实现了用户登录和注册功能，以及提供滑动分页控制器`TTPagerViewController`。

`TTPagerViewController`初始化时延迟挂在子VC视图到页面上，离开页面时触发`onPageLeave`回调移除播放器并替换playerItem为nil以节约内存；进入新页面时触发`onPageEnter`回调，若子VC视图已挂载则恢复播放器，若未挂载子VC视图则挂在子VC视图。

用户注册成功之后将用户的账号密码自动填入到登录页面中并导航回登录页面，此时点击登录若登录成功则跳转到个人信息页面。

## :hotsprings: 模块具体实现

### 主页短视频模块

![image.png](https://s2.loli.net/2022/07/15/6EbBMnYJxmR3Phv.png)

#### 下方标签栏实现

标签栏使用原生的`UITabBarController`实现，一共分为三个`Tab`，分别是主页、上传和我的，其中上传的`Tab`使用按钮替代，实现方法是添加`UIButton`遮盖，在`UITabBar`中间位置添加一个自定义按钮，当`tabBarController`代理方法检测到点击的是中间那个控制器时，通过代理拦截，替换成自定义的按钮方法。

![image.png](https://s2.loli.net/2022/07/15/7ChUZryWVBb3DsH.png)

#### 视频源上下滑动实现

视频源上下滑动部分使用`UITableView`控件封装每个短视频作品，每个作品是一个`UITableViewCell`，每个`cell`都占满整个屏幕，由视频的封面作为背景图，最前方是播放器视图。`UITableView`的重用机制在实现上下滑动切换视频源时，可以很大程度降低创建控件所需要的开销。

![image.png](https://s2.loli.net/2022/07/15/QIEaNg2CjwntUxS.png)

![image.png](https://s2.loli.net/2022/07/15/PIR1bEkG6cZyLoW.png)

通过`scrollViewDidEndDragging`代理方法的坐标差来判断滑动后是否改变`UITableView`的索引，如果坐标差的y超过100个单位，即改变索引值，通过`scrollToRowAtIndexPath`方法滑动到指定的`cell`。

通过`KVO`监听`UITableView`索引属性值的变化，一旦索引发生改变，则切换视频源，切换到新的`cell`。

#### 视频数据加载

视频数据通过`AFNetworking`向后台接口请求资源，通过`MJExtension`解析完后放入数组，当滑动到数组的`70%`部分时，通过`willDisplayCell`代理方法进行数据预加载，异步获取更多的数据放到数组中，获得数据后在主线程刷新。

视频Model：

```Objective-C
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, copy)   NSString *pictureToken;
@property (nonatomic, copy)   NSString *videoToken;
@property (nonatomic, copy)   NSString *uploader;
@property (nonatomic, copy)   NSString *uploaderToken;
@property (nonatomic, copy)   NSString *name;
```

![image.png](https://s2.loli.net/2022/07/15/aTmx1IAvSUgqEQz.png)

拿到`token`后，通过后台的文件下载接口获取到视频和图片资源，这里需要注意的是，在使用`AVPlayer`时视频资源正常`response`返回的状态码应该是`206`，因为当`AVPlayerItem`拿到视频URL时，它会先发送一个`byte range request`，例如`range = 0-1`，代表请求第一个字节到第二个字节的文件部分，如果响应代码为`206`并返回1个字节的数据，则继续发送其他HTTP请求，以下载其他文件段。否则执行`AVErrorServerIncorrectlyConfigured`错误。

`range头域`是`HTTP1.1`中在请求头新引入的特性，它允许只请求资源的某个部分，即返回码`206（Partial Content）`，方便开发者自由选择便于充分利用带宽。

#### 视频播放器实现

`AVFoundation`框架下的`AVPlayerLayer`是`AVPlayer`的可视化输出对象，本项目使用`AVPlayerLayer`实现视频播放功能。

视频进度条：

![image.png](https://s2.loli.net/2022/07/15/ATqomvyJpkh4lun.png)

```Objective-C
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *countTimeLabel;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UIButton *startVideoBtn;
@property (nonatomic, strong) UIButton *changeFullScreenBtn;
@property (nonatomic, strong) UISlider *slider;
```

`sliderView`主要用于响应单击手势，用于隐藏或显示进度条，`bottomView`用于装载进度条的控件，包括视频总时间和当前时间的`Label`，以及播放和全屏按钮和进度条`UISlider`，进度条的拖动事件实现为先获取拖动完的值，然后构造`CMTime`，播放器再通过`seekToTime`方法移动过去。

```Objective-C
typedef struct {
    CMTimeValue value; // 分子
    CMTimeScale timescale; // 分母
    CMTimeFlags flags; // 位掩码，表示时间的指定状态
    CMTimeEpoch epoch;
} CMTime; // CMTime以分数的形式表示时间。
```

全屏播放实现：

![image.png](https://s2.loli.net/2022/07/15/iHfDw7xomeb89dP.png)

实现方法为用transform的方式做一个旋转动画。

长按倍速播放：

```Objective-C
// 创建长按手势
UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imglongTapClick:)];
[self.view addGestureRecognizer:longTap];
```

创建一个长按手势，长按实现加速播放，释放后恢复正常倍速。

```Objective-C
// 长按加速播放，释放后恢复
- (void)imglongTapClick:(UILongPressGestureRecognizer *)gesture {
    if (self.avPlayerView.startVideoBtn.selected == NO) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            self.avPlayerView.player.rate = 2.0;
        } else {
            self.avPlayerView.player.rate = 1.0;
        }
    }
}
```

#### 视频缓存实现

视频缓存使用了一个基于`AVPLayer`的短视频播放缓存库`ShortMediaCache`。基本功能是短视频内容的下载，预加载和缓存管理。

![image.png](https://s2.loli.net/2022/07/15/ecYrDO4T5WjH9JE.png)

**`ShortMediaCache`**如何从缓存播放：

![image.png](https://s2.loli.net/2022/07/15/h73OjtJnBrvcSVi.png)

`AVPlayer`连接播放器层与缓存层的数据交互是通过自定义实现`AVAssetResourceLoaderDelegate`协议实现的，在播放器加载的过程中，播放器会通过`AVPlayerItem`向`AVURLAsset`的`resourceLoader`获取需要加载数据信息，比如加载的数据偏移，大小等，最终这些数据请求（AVAssetResourceLoadingRequest）会到达其代理（AVAssetResourceLoaderDelegate）对象，代理对象根据请求数据的位置和大小，去读取相关文件缓存数据，然后回填给请求，以此来响应播放器的数据缓冲请求，与此同时缓存层通过网络请求将下载下来的数据写入文件保存。

对于`AVAssetResourceLoaderDelegate`协议主要需要实现以下方法：

```Objective-C
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest;
```

播放器的数据加载请求会放到`loadingRequest`里面，通过其`dataRequest`对象的`requestedOffset`和`requestedLength`可以知道本次数据请求的区块，从缓存文件中按需读取数据填充后执行`finishLoading`方法即可完成本次数据请求。

```Objective-C
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest;
```

**`ShortMediaCache`**如何下载：

对于下载应该放到子线程中去通过`NSURLSession`来实现，因为视频文件可能之前已经缓存了部分，需要从已缓存的位置大小处继续下载缓存，在每次开启下载前需要去读取已缓存文件的大小，并设置请求头部字段`Range`便可从此处继续下载后面未下载的部分。

```Objective-C
NSString *range = [NSString stringWithFormat:@"bytes=%ld-", (long)cachedSize];
[downloadRequest setValue:range forHTTPHeaderField:@"Range"];
```

每次下载到的数据可以直接`append`到缓存文件末尾。 因为短视频的播放首要任务就是保证当前单个视频的流畅播放，所以在理论上只会存在一个下载任务来独享所有的下载带宽，当在空闲状态的情况下才适合去做其他的短视频资源的预加载。

**`ShortMediaCache`**的缓存管理：

缓存主要创建了三个目录管理，分别为`temp`、`media`和`trash`目录，缓存分为临时缓存和最终缓存，当短视频资源未下载完时是放在一个目录下的（temp目录）、而当视频资源缓存完时移动到另外一个目录（media），这样分别存放便能方便读取和管理两种状态的缓存，所有需要删除的缓存文件都是先移入`trash`目录，随后再删除以此来保证较高的删除效率。所有文件命名使用的是视频资源的url md5值保证唯一性。

缓存应该具有自动管理功能，以防止其无限膨胀，默认配置下`ShortMediaCache`允许临时缓存最多保存1天，最大100Mb，而最终缓存则允许最多保存2天最大200Mb。

**`ShortMediaCache`**的预加载：

预加载的下载任务应该和正常的边下边播任务区分开，首先应该保证正在播放的短视频能顺畅的播放，所以边下边播任务优先级应该高于预加载任务，在没有边下边播任务时才能执行预加载任务，并且当有新的边下边播任务时应当停止当前的预加载任务，首要执行边下边播任务。

`ShortMediaCache`提供了预加载功能实现，通过调用`ShortMediaManager`以下方法：

```Objective-C
- (void)resetPreloadingWithMediaUrls:(NSArray<NSURL *> *)mediaUrls;
```

可以多次调用此方法，来不断更新需要预加载的资源队列。

### 搜索页面模块

![image.png](https://s2.loli.net/2022/07/15/D1Uc4KVazYSJjtm.png)

#### 搜索页

在主页中，用户输入文本后，跳转后可将文本显示在搜索框，此功能点通过重写搜索页的`init()`方法，在创建`TTSearchViewController`时能够把文本传进来。用户点击`cell`即可跳转播放页。

![image.png](https://s2.loli.net/2022/07/15/LvUZSypzKsFxg3Q.png)

#### 请求数据

搜索页和视频播放页请求数据的方式相同，为避免代码冗余，则将请求数据部分交由模型内部处理。若请求成功则返回数组，失败则返回错误信息。

`TTSearchModel`的属性和方法如下：

```Objective-C
@interface TTSearchModel : NSObject

@property (nonatomic, copy) NSString *imgIcon;  // 头像
@property (nonatomic, copy) NSString *usrName;  // 用户名
@property (nonatomic, copy) NSString *videoTitle;   // 视频标题
@property (nonatomic, copy) NSString *videoImg; // 视频图片
@property (nonatomic, copy) NSString *video;    // 视频

+ (void)searchModelWithSuccess:(void(^)(NSArray *array))success fail:(void(^)(NSError *error))fail text:(NSString *)text current:(NSInteger)current size:(NSInteger)size;     // 发送请求获取数据
+ (TTSearchModel *)getModelWithRecord:(TTWorkRecord *)record;   // 模型转化

@end
```

对请求获得的响应体进行解析后所得的record，由于record包含的是视频或图片的token，后续仍需进行拼接才能获得相应的URL，为方便后续`UIViewController`能直接获取模型数据进行播放和显示，故在`TTSearchModel`内部将token拼接好，返回一个直接可用的模型，具体实现方法为上述的模型转化方法。内部主要代码如下（以拼接视频URL为例、创建模型并赋值）：

```Objective-C
    NSString *video = [TTNetworkTool getDownloadURLWithFileToken:record.videoToken];
    
    TTSearchModel *model = [[TTSearchModel alloc] init];
    model.video = video;
    
    return model;
```

`UIViewController`通过调用`TTSearchModel`中的请求数据方法，若请求成功获得数据数组后，把数组赋值给自身的模型数组属性，以进行控件属性的赋值，并且由于是异步请求，发起请求后，即`UIViewController`调用`TTSearchModel`中的请求方法后会往下执行，导致`tableView`数据未能显示出来，故修改`UIViewController`中模型数组属性的set方法，在数组赋值后进行`tableView`刷新。主要代码如下：

```Objective-C
    _modelArray = modelArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchTableView reloadData];
    });
```

#### 加载

搜索页使用第三方库`MJRefresh`进行分页加载。设置`tableView`的`mj_header`和`mj_footer`，前者为了实现下拉刷新，后者为实现加页。搜索页所用的`TTSearchViewController`中用`current`属性记录页数，每次请求（调用`loadDate()`方法）后会对current+1。若请求得到的数组长度小于一页的数据长度（`size`），则将`mj_footer`的状态设为`MJRefreshStateNoMoreData`状态以提示用户没有更多数据，后可通过下拉刷新再次请求。

![image.png](https://s2.loli.net/2022/07/15/RqwvQmsDz7tpXY1.png)

#### 视频播放页

由于本模块的视频播放页获取的数据模型与主页的不同并且控件有所增加，故采取继承的方式，在父类的基础上做修改，以便于后续调整，同时也具有主页短视频播放的相关功能。

继承后新增返回键功能。用于返回搜索页，返回前通过观察者监听，点击返回键则发送通知暂停视频播放。

![image.png](https://s2.loli.net/2022/07/15/JVFGUql2ebmCLaQ.png)

由于数据获取的方法不同，故需要重写部分方法，如`tableView`的代理方法、`loadData()`等方法。其中由于视频播放页与搜索页获取数据相同，故实现方法与搜索页相同。

### 个人主页模块

![image.png](https://s2.loli.net/2022/07/15/H6uxfjAzLRBZvho.png)

#### 个人主页实现

个人主页由UITableView 构成，其中为了让主页信息随着视频列表一起滑动，上部分页面直接添加到TableView的headerView。

headerView由自定义的view、UserInfoView填充，其中分为四个部分，头像ImageView，标签容器containLabel和数据容器containLabel，更新信息按钮updatButton，使用masonry对四个组件来进行约束。标签与数据采用UIStackView可以更容易进行布局与对其两边的数据。

下部分的列表信息由自定义的UserInfoCell构成，这里只保留了标题与图片，图片通过SDWebImageView来进行url图片的展示，其中标题标签的位置决定了整个cell的高度，通过获取view的大小来进行实时计算得出。

![image.png](https://s2.loli.net/2022/07/15/4J1OlBVrUdqjAin.png)

#### **更新个人信息实现** 

更新个人信息模块为一个新的VC，TTUupdateInfoController,同样由UIStackView来构成，这样可以更方便的布局同时保证标签的对齐，其中填写模型复用了注册模块的TTInputField，可以保证整体ui的统一，同时也复用了其中对输入框的布局。

controller遵守了UITextField的协议，在其中的委托方法中获取输入的数据，对其中的值进行数据校验，通过正则表达式校验

页面的两个按钮为更新和退出登录，分别绑定两个事件，点击更新按钮后会向服务端发送数据，点击退出登录则是到userDefault删除其中存储的token值，方面后续继续展示登录界面。

![image.png](https://s2.loli.net/2022/07/15/bHBSs14d6phjk5V.png)

#### 接口信息获取

本模块一共调用了两个接口

**获取个人信息数据**  47.96.114.143:62318 /api/user/getUserInfo GET

![image.png](https://s2.loli.net/2022/07/15/7t6VkIuPl3Bb4Ro.png)

对应使用GetUserInfoData模型接收

```Objective-C
@interface TTGetUserInfoData : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, strong) NSString *pictureToken;
@property (nonatomic, strong) TTWorksListData *worksList;
@end
```

**更新个人信息** 47.96.114.143:62318 /api/user/updateUserInfo Post

![image.png](https://s2.loli.net/2022/07/15/v1ghIbk8KDWUJrM.png)

对应的request由TTUpdateUserofRequest构造，其继承于TTRegisterRequest

```Objective-C
@interface TTRegisterRequest : TTBaseRequest
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *mail;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *name;
@end
```

### 用户登录模块+上方导航栏

#### 登录注册模块

实现了用户登录和注册功能，以及提供滑动分页控制器`TTPagerViewController`。

![image.png](https://s2.loli.net/2022/07/15/s2PgyYAxzXd7J1R.png)

- 输入框`TTInputField`
  - 简介
    - 输入框分为两种类型，分别是普通输入框和密码输入框；
    - 区别：密码输入框尾部按钮可切换密码文本可见性。
  - ```Objective-C
    typedef NS_ENUM(NSInteger, TTInputFieldType) {
        TTInputFieldTypeNormal,  // 普通输入框
        TTInputFieldTypePassword // 密码输入框    
    };
    ```

  - 初始化普通样式（非密码样式输入框）如下：
  - ```Objective-C
    _usernameInputField = [[TTInputField alloc]initWithLabelText:@"账号" placeholder:@"请输入账号" type:TTInputFieldTypeNormal];
    ```

  - 初始化密码样式输入框如下：
  - ```Objective-C
    _passwordInputField = [[TTInputField alloc]initWithLabelText:@"密码" placeholder:@"请输入密码" type:TTInputFieldTypePassword];
    ```

  - 界面展示
    - 如图所示，账号输入框为普通输入框，密码输入框为密码输入框。
  - ![image.png](https://s2.loli.net/2022/07/15/3qZkJSG1KEhl7b8.png)

  - 头文件声明
  - ```Objective-C
    NS_ASSUME_NONNULL_BEGIN
    
    @interface TTInputField : UIView
    @property (nonatomic, strong) UITextField *textField;
    @property (nonatomic, copy) NSString *labelText;
    @property (nonatomic, strong) UIStackView *containerView;
    @property (nonatomic, copy) NSString *placeholder;
    - (instancetype)initWithLabelText:(NSString *)labelText placeholder:(NSString *)placeholder type:(TTInputFieldType)type;
    @end
    
    NS_ASSUME_NONNULL_END
    ```

  - `TTInputField`布局实现
    - 将子`View`挂载到`UIStackView`下组合；
    - ```Objective-C
      // 水平栈，沿x轴垂直方向居中
      _containerView.axis = UILayoutConstraintAxisHorizontal;
      _containerView.alignment = UIStackViewAlignmentCenter;
      ```

    - 添加边距，由于`UIStackView`中`arrangedSubviews`是等距分布的，所以采用向`UITextField`添加左右空白`UIView`的方式实现左右边距；
    - 切换可见性按钮使用了一个固定宽度为30的`UIStackView`抵抗压缩。

- 个人主页Tab
  - 个人主页将显示时判断token是否存在，若存在且未过期则显示个人主页界面；若未存在或者已过期则删除token和token过期时间并导航到登录界面。
  - ```Objective-C
    - (void)viewWillAppear:(BOOL)animated {
        // 获取UserDefaults
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        // 获取token
        NSString *token = [ud valueForKey:@"token"];
        BOOL tokenExpired = NO;
        // 获取token过期时间
        NSDate *expireAt = [ud valueForKey:@"expireAt"];
        NSDate *currentTime = [NSDate date];
        // 比较token过期时间和当前时间
        if ([expireAt compare:currentTime] == NSOrderedAscending) {
            // 如果token已过期则从UserDefaults中删除相关属性
            [ud removeObjectForKey:@"token"];
            [ud removeObjectForKey:@"expireAt"];
            tokenExpired = YES;
        }
        // 登录状态有效就发起网络请求获取个人信息；登录状态无效就导航到登录界面
        if (token == nil || tokenExpired) {
            [self navToLoginWithAnimation:NO];
        } else {
            [self performLoginRequest];
        }
    }
    ```

- 用户登录流程
  - 用户输入账号和密码，输入后点击回车调用`textFieldShouldReturn:`跳转到下一个输入框；
  - 校验输入框是否合法，若有则调用`showAlertWithTitle:`提示对应输入框的不合法信息；
  - 准备发送网络请求，通过`self.isPerformingRequest`检查是否有正在发送的登录请求，若有则`loginAction`提前返回并且调用`showAlertWithTitle:`提示上一个登录请求仍在处理中；
  - 接受返回的网络请求，使用`MJExtension`将JSON转为Model。

- 用户注册流程
  - 和用户登录流程相似，多了对于邮箱格式的正则表达式校验；
  - ```Objective-C
    NSString *const kEmailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    ```

  -  注册成功后，返回上一个页面(登录页面进行用户登录)。

#### 滑动分页模块

- 原理
  - `TTPagerViewController`下挂`UIScrollView`容器，用于放置多个为屏幕宽度的子VC
  - 将容器的`contentSize`设为屏幕宽度*子VC数量；
  - 滑动或点击按钮的时候通过更新`sliderNav`的约束实现滑动指示功能。

![image.png](https://s2.loli.net/2022/07/15/J5qCW6a3InuHfwg.png)

- 滑动分页指示器`TTSliderNavView`
  - 界面展示
  - ![image.png](https://s2.loli.net/2022/07/15/9PgG3JoLZDWr5I1.png)

  - `TTSliderNavView`定义
  - ```Objective-C
    NS_ASSUME_NONNULL_BEGIN
    
    @interface TTSliderNavView : UIView
    @property (nonatomic, strong) UIScrollView *container;/// 挂载子视图的容器
    @property (nonatomic, strong) NSArray <UIButton *> *buttonArray;/// 标签页按钮
    @property (nonatomic, strong) UILabel *sliderLabel; /// 滑块标识
    @property (nonatomic, assign) BOOL canInteract; /// 用于防止动画过程中用户操作触发其他动画
    @property (nonatomic, assign) BOOL isButtonClicked; /// 判断是否用户点击，若为NO则为滑动容器切换子视图
    - (instancetype)initWithButtonTitles:(NSArray <NSString *> *)buttonTitles; /// 初始化时需要标签页按钮标题数组
    - (UIButton *)buttonWithTag:(NSInteger)tag; /// 根据button对应tag从container获取对应button
    - (void)setupSubViews; /// 暴露子视图布局方法，初始化后装载时调用
    - (instancetype)init NS_UNAVAILABLE;
    - (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
    - (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
    @end
    
    NS_ASSUME_NONNULL_END
    ```

- 滑动分页控制器`TTPagerViewController`
  - 定义
  - ```Objective-C
    @class TTSliderNavView;
    typedef void(^OnPageLeave)(NSUInteger currentIndex, UIViewController * _Nullable currentVC);
    typedef void(^OnPageEnter)(NSUInteger currentIndex, UIViewController * _Nullable currentVC);
    NS_ASSUME_NONNULL_BEGIN
    
    @interface TTPagerViewController : UIViewController
    @property (nonatomic, strong) NSArray <UIViewController *> *childrenVCArray; // 强持有子VC数组
    @property (nonatomic, strong) UIScrollView *container; /// 下挂视图容器
    @property (nonatomic, assign) NSUInteger currentIndex; /// 记录当前页面位置
    @property (nonatomic, strong) UISearchBar *searchBar; /// self.view下搜索框
    @property (nonatomic, assign) BOOL showSearchBar;
    @property (nonatomic, strong) TTSliderNavView *ttSliderNav; /// self.view下滑动指示器
    @property (nonatomic, strong) OnPageLeave onPageLeave; /// 页面换出回调
    @property (nonatomic, strong) OnPageEnter onPageEnter; /// 页面换入回调
    - (instancetype)init NS_UNAVAILABLE;
    - (instancetype)initWithChildrenVCArray:(NSArray <UIViewController *> *)childrenVCArray titles:(NSArray <NSString *> *)titles showSearchBar:(BOOL)showSearchBar onPageLeave:(OnPageLeave)onPageLeave onPageEnter:(OnPageEnter)onPageEnter;
    @end
    
    NS_ASSUME_NONNULL_END
    ```

  - 原理
    - 点击顶部按钮滑动实现
    - ```Objective-C
      - (void)sliderAction:(UIButton *)sender {
          NSInteger nextIndex = [self indexFromTag:sender.tag];
          // 判断重复选中或者正在动画状态，直接返回
          if (_currentIndex == nextIndex || !_ttSliderNav.canInteract) {
              return;
          }
          // 取消先前激活按钮
          UIButton *currentSelectedButton = [_ttSliderNav buttonWithTag: [self tagFromIndex:_currentIndex]];
          NSLog(@"%@", currentSelectedButton.description);
          [currentSelectedButton setSelected:NO];
          [self animateWithTag:sender.tag];
          // 设置为按钮点击状态，防止动画冲突
          _ttSliderNav.isButtonClicked = YES;
          // 容器滚动动画
          [UIView animateWithDuration:0.3 animations:^{
              self->_container.contentOffset = CGPointMake(UIScreen.mainScreen.bounds.size.width*(nextIndex), 0);
          } completion:^(BOOL finished) {
              // 释放按钮点击状态
              self->_ttSliderNav.isButtonClicked = NO;
          }];
      }
      ```
  - 滑动和点击按钮共用部分，若为滑动则起到归位作用，点击按钮则全程依赖此方法移动指示条；更新下标时触发`onPageLeave`和`onPageEnter`回调，将`self`作为`block`的参数传到`block`里面，vc参数在`block`调用过程中作为临时变量被压栈进来，栈内存由系统自动管理，所以不会产生retain cycle。
  - ```Objective-C
    - (void)animateWithTag:(NSInteger)tag {
        // 按钮宽度
        CGFloat widthMetric = _ttSliderNav.frame.size.width / 3;
        // sliderNav容器宽度
        CGFloat sliderWidth = _ttSliderNav.sliderLabel.frame.size.width;
        // 滑动指示器
        UILabel *sliderLabel = _ttSliderNav.sliderLabel;
        UIScrollView *sliderContainer = _ttSliderNav.container;
        // 禁止动画结束前交互
        _ttSliderNav.canInteract = false;
        [UIView animateWithDuration:0.3 animations:^{
            [sliderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left
                    .mas_equalTo(sliderContainer.mas_left)
                    .offset((widthMetric - sliderWidth)/2 + ([self indexFromTag:tag]) * widthMetric);
            }];
            // 手动提示sliderNav父视图重新布局，否则动画不会生效
            [self->_ttSliderNav layoutIfNeeded];
        } completion:^(BOOL finished) {
            // 允许用户交互
            self->_ttSliderNav.canInteract = YES;
        }];
        // 选中对应按钮
        [[_ttSliderNav buttonWithTag:tag]setSelected:YES];
        NSLog(@"scroll end: %zd", _currentIndex);
        // 更新下标
        NSUInteger nextIndex = [self indexFromTag:tag];
        NSUInteger currentIdx = _currentIndex;
        // onPageEnter和onPageLeave提供函数入参self和currentIndex
        if (_onPageLeave) {
            _onPageLeave(currentIdx, self);
        }
        _currentIndex = nextIndex;
        // 如果nextIndex对应的子视图未添加，则将子视图添加到滑动容器中的对应位置
        [self addChildrenViewToContainerWithIndex:nextIndex];
        if (_onPageEnter) {
            _onPageEnter(nextIndex, self);
        }
    }
    ```

  - 实现`UIScrollViewDelegate`对应方法
  - ```Objective-C
    // 监听滑动事件开始，激活约束使sliderNav下指示器根据滑动滚动
    - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        // 若为按钮点击引起的滑动，则直接返回
        if (_ttSliderNav.isButtonClicked) {
            return;
        }
        // 计算当前slider偏移量
        CGFloat currentOffSetX = _container.contentOffset.x;
        CGFloat sliderOffsetX = currentOffSetX / (_ttSliderNav.buttonArray.count + 0.5) ;
        // 更新约束，使slider同步容器滚动
        [_ttSliderNav.sliderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_ttSliderNav.container.mas_left).offset(sliderOffsetX + (_ttSliderNav.frame.size.width / _ttSliderNav.buttonArray.count - _ttSliderNav.frame.size.width / (_ttSliderNav.buttonArray.count + 1)) / 2);
        }];
        // 通知sliderNav的容器重新布局
        [_ttSliderNav.container layoutIfNeeded];
    }
    
    // 监听滚动事件结束减速（真正停止）
    - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
        // 拿到上一个页面下表对应按钮tag
        NSInteger previousTag = [self tagFromIndex:_currentIndex];
        // 取消激活
        [[_ttSliderNav buttonWithTag:previousTag]setSelected:NO];
        // 根据容器滑动偏移量计算下一个页面对应的按钮tag
        NSInteger nextTag = [self tagFromIndex:(NSUInteger) (scrollView.contentOffset.x / UIScreen.mainScreen.bounds.size.width)];
        // 开始动画
        [self animateWithTag:nextTag];
    }
    ```

- 使用例
  - 定义`onPageEnter`和`onPageLeave`回调方法以供初始化：
  - ```Objective-C
    OnPageEnter onPageEnter = ^(NSUInteger currentIndex, UIViewController *_Nullable currentVC) {
        if (!currentVC || ![currentVC isKindOfClass:TTPagerViewController.class]) {
            return;
        }
        TTPagerViewController *currentPagerViewController = (TTPagerViewController *)currentVC;
        [currentPagerViewController startPlayingCurrent];
    };
    OnPageLeave onPageLeave = ^(NSUInteger currentIndex, UIViewController *_Nullable currentVC) {
        if (!currentVC || ![currentVC isKindOfClass:TTPagerViewController.class]) {
            return;
        }
        TTPagerViewController *currentPagerViewController = (TTPagerViewController *)currentVC;
        [currentPagerViewController stopPlayingCurrentWithPlayerRemoved: YES];
    };
    ```

  - 初始化方法
  - ```Objective-C
    [[TTPagerViewController alloc] initWithChildrenVCArray:childrenArray.copy titles:typeListResponse.data showSearchBar:YES onPageLeave:onPageLeave onPageEnter:onPageEnter];
                vcHomePage.navigationController.navigationBar.hidden = YES;
                [navHomePage pushViewController:vcHomePage animated:NO];
    ```
