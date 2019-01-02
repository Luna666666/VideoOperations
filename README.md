![mahua](http://upload-images.jianshu.io/upload_images/259-0ad0d0bfc1c608b6.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# VideoOperations

## VideoOperations是什么?
一个基于Objective-C语言开发的高内聚低耦合的iOS开发框架

向VideoOperations的开发者Michael Chan致敬!

## VideoOperations主要功能？

* AVPlayer 视频离线缓存、可以边下边播放、部分缓存、断网处理、AVAssetResourceLoaderDelegate

## 更新记录
2018.12.29 -- v0.0.1:提交0.0.1版本并完成框架搭建和核心功能模块编写

## 使用方式
1.0 下载VideoOperations直接运行

## 注意事项
1. 熟悉Objective-C基本语法

## 有问题反馈
在使用中有任何问题，欢迎反馈给我，可以用以下联系方式跟我交流
* 邮件(951123604@qq.com)
* QQ: 951123604
* weibo: [@xiaoqiang是个小疯子](https://weibo.com/p/1005055732746027/home?from=page_100505&mod=TAB#place)
* twitter: [@CharlesDing8](https://twitter.com/CharlesDing8)

## 捐助开发者
在兴趣的驱动下,写一个`免费`的东西，有欣喜，也还有汗水，希望你喜欢我的作品，同时也能支持一下。
当然，有钱捧个钱场（右上角的爱心标志，支持支付宝和PayPal捐助），没钱捧个人场，谢谢各位。

## 感激
感谢以下的项目,排名不分先后

* [mou](http://mouapp.com/) 
* [ace](http://ace.ajax.org/)
* [jquery](http://jquery.com)

# 你的Star是我更新的动力，使用过程如果有什么问题或者有什么新的建议，可以issues,我会及时回复大家！

``` objc
 #import <TTPlayerCache.h>
...
//把视频播放地址转成系统不能识别的URL
NSString *videoUrl = @"http://....";
BOOL isMP4 = YES; //是否是mp4格式
videoUrl = isMP4? TTResourceUrlFromOrigianllUrl(videoUrl): videoUrl;
...
...
//设置AVPLayer播放
//初始化代理
self.resourceLoaderDelegate = [TTResourceLoaderDelegate new];
self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
[self.urlAsset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:TT_resourceLoader_delegate_queue()];

```

