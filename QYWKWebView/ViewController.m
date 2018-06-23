//
//  ViewController.m
//  QYWKWebView
//
//  Created by liuming on 2018/6/13.
//  Copyright © 2018年 yoyo. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "NCChineseConverter.h"
#define KRedirectUrlToGamePage @"KRedirectUrlToGamePage"
#define KWebUrlLoadCompleted   @"KWebUrlLoadCompleted"
@interface ViewController ()<WKUIDelegate, WKNavigationDelegate,WKScriptMessageHandler>
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) WKNavigation *navigation;

@property(nonatomic, strong)NSString * teamA;
@property(nonatomic,strong) NSString * treamB;

@property(nonatomic,assign)BOOL isLoadingGameUrl;

@property(nonatomic,assign)BOOL allowNewPage;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    WKWebViewConfiguration *webConfiguration = [self webConfiguration];
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.webView = [[WKWebView alloc] initWithFrame:rect configuration:webConfiguration];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    self.allowNewPage = YES;
    
    self.teamA = @"尼日利亞";
    self.treamB = @"冰島";
    
    //https://mobile.7788365365.com/#type=InPlay;key=;ip=1;lng=2   https://www.baidu.com
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://mobile.7788365365.com/#type=InPlay;key=;ip=1;lng=2"]];
    self.navigation = [self.webView loadRequest:requst];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:@"estimatedProgress"];
}

#pragma mark UIDelegate
//创建一个新的WebView
- (nullable WKWebView *)webView:(WKWebView *)webView
 createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
            forNavigationAction:(WKNavigationAction *)navigationAction
                 windowFeatures:(WKWindowFeatures *)windowFeatures
{
    return self.webView;
}

- (void)webViewDidClose:(WKWebView *)webView {}

- (void)webView:(WKWebView *)webView
    runJavaScriptAlertPanelWithMessage:(NSString *)message
                      initiatedByFrame:(WKFrameInfo *)frame
                     completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"message = %@",message);
    completionHandler();
}

// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    completionHandler(@"http");
}
- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo{
    
    return YES;
}
- (nullable UIViewController *)webView:(WKWebView *)webView
    previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo
                        defaultActions:(NSArray<id<WKPreviewActionItem>> *)previewActions
{
    return self;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
    
    
}
#pragma mark WKNavigationDelegate

//// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"open url %@", navigationAction.request.URL.absoluteString);
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"can open  url %@", navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    // decisionHandler(WKNavigationResponsePolicyCancel);
}

//页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"webView start load webUrl");
}
//// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    
    NSLog(@"webView commit webUrl");
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    NSLog(@"网页完全加载好");
    [self testPageLoadFinish];
}
//页面加载完成之后调用
- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
                       withError:(NSError *)error
{
}
//// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView
    didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(null_unspecified WKNavigation *)navigation
            withError:(NSError *)error
{
}

//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
                    completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
                                                NSURLCredential *_Nullable credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential,nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"receive script message name = %@ body = %@",message.name,message.body);
    
    if (![message.name isEqualToString:@"callbackHandler"])
    {
        NSDictionary * bodyDic = [[NSDictionary alloc] initWithDictionary:message.body];
        NSString * bodyName = bodyDic[@"name"];
        if ([bodyName isEqualToString:KRedirectUrlToGamePage])
        {
            [self testGameContextView];
        }
    }
}
#pragma mark -配置webConfig
- (WKWebViewConfiguration *)webConfiguration
{
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    config.preferences = [[WKPreferences alloc] init];
    config.processPool = [[WKProcessPool alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"webKitTest"];
    [self addHelloWorldAlertScript:config.userContentController];
    return config;
}

- (void)addHelloWorldAlertScript:(WKUserContentController *)userContentController
{
    if (userContentController)
    {
        WKUserScript * userScript = [[WKUserScript alloc] initWithSource:@"alert('hello world')" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        [userContentController addUserScript:userScript];
        
        NSString *jsHandler = [NSString stringWithContentsOfURL:[[NSBundle mainBundle]URLForResource:@"AjaxHandler" withExtension:@"js"] encoding:NSUTF8StringEncoding error:NULL];
        WKUserScript *ajaxHandler = [[WKUserScript alloc]initWithSource:jsHandler injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [userContentController addScriptMessageHandler:self name:@"callbackHandler"];
        [userContentController addUserScript:ajaxHandler];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([((__bridge NSString *)context) isEqualToString:@"estimatedProgress"])
    {
        NSLog(@"progress == %f",self.webView.estimatedProgress);
    }
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}


#pragma mark -
- (void)searchMatch
{
    NSLog(@"当前的比赛队名 %@-------%@",self.teamA,self.treamB);
    
    NSString * team_a = [[NCChineseConverter sharedInstance] convert:[self.teamA substringToIndex:1]
                                                            withDict:NCChineseConverterDictTypezh2TW];
    NSString * team_b = [[NCChineseConverter sharedInstance] convert:[self.treamB substringToIndex:1]
                                                            withDict:NCChineseConverterDictTypezh2TW];
    
    NSString * searchCode= [NSString stringWithFormat:@"function postStr(){  var doingmatch=document.getElementsByClassName('ipo-Fixture_CompetitorName ');"
                            "var teamaNames=new Array();"
                            "var teambNames=new Array();"
                            "var res;"
                            "for (var i = 0;i <doingmatch.length;i++){"
                            "if (i%%2 == 0)"
                            "{"
                                "teamaNames.push(doingmatch[i].innerText);"
                            "}"
                            "else"
                            "{"
                            "teambNames.push(doingmatch[i].innerText);"
                            "}"
                            "}"
                            "for (var i = 0;i <teamaNames.length;i++)"
                            "{"
                            "var temp_a = teamaNames[i];"
                            "var temp_b = teambNames[i];"
                            "if(temp_a.indexOf('%@')!=-1 && temp_b.indexOf('%@')!=-1)"
                            "{"
                            "alert('%@');"
                            "doingmatch[i*2].click();"
                            "window.webkit.messageHandlers.webKitTest.postMessage({'name':'KRedirectUrlToGamePage'});"
                            "res='ok';"
                            "return res;"
                            "} else {alert( temp_a + '||' +  temp_b)}"
                            "} return 'unfind'} postStr();",team_a,team_b,[NSString stringWithFormat:@"%@v%@直播比赛正常解析正常",team_a,team_b]];
    [self.webView evaluateJavaScript:searchCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        NSLog(@"result = %@",result);
        
    }];
}


- (void)testGameContextView
{
    NSString * js = @"function test3 (){var svg =$('.ip-MatchLiveContainer'); if(svg.length > 0){return 'OK';} return 'NO'}  test3()";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        if (error)
        {
            NSLog(@"error = %@",[error userInfo]);
        }
        else
        {
            NSLog(@"testGameContextView = %@",result);
            if ([[result uppercaseString] isEqualToString:@"OK"])
            {
                NSLog(@"lllllllllllllllllll");
                [self hidView];
            }
            else if([[result uppercaseString] isEqualToString:@"NO"])
            {
                [self performSelector:@selector(testGameContextView) withObject:nil afterDelay:0.5];
                
            }
        }
    }];
    
}
//打开第二个页面
- (void)hidView
{

    NSString * hiddenCode = @"$('#FooterContainer,.ml1-MatchLiveSoccerModule_LocationsMenuConstrainerNarrow,.g5-HorizontalScroller_HScroll,.ipe-EventViewTitle,.v5,.MarketGrid,.ipe-MarketGrid_Classification-1,.hm-HeaderPod_Nav ,.state-LoggedOut,.hm-HeaderModule_Narrow,.hm-HeaderModule ,.ml1-ModalController_Icon,.ml1-ModalController_Icon-Summary,.ml1-ModalController_Icon,.ml1-ModalController_Icon-Table ').hide();";
    
    NSLog(@"隐藏元素\n %@",hiddenCode);
    
    [self.webView evaluateJavaScript:hiddenCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        [self.webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id _Nullable height, NSError * _Nullable error) {
                NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", [height integerValue]];
            [self.webView evaluateJavaScript:javascript completionHandler:^(id _Nullable resutl, NSError * _Nullable error) {
            }];
        }];
    }];
}
- (void)testPageLoadFinish
{
    NSString * js = @"function test (){var display =$('#preLoadOuter').css('display'); if(display == 'none'){return 'OK' } return 'NO'}; test()";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"error = %@",[error userInfo]);
        }
        else
        {
            NSLog(@"testPageLoadFinish = %@",result);
            if ([[result uppercaseString] isEqualToString:@"OK"])
            {

                [self performSelector:@selector(testLoadViewExist) withObject:nil afterDelay:0.3];
            }
            else if([[result uppercaseString] isEqualToString:@"NO"])
            {

                [self performSelector:@selector(testPageLoadFinish) withObject:nil afterDelay:0.5];

            }
        }

    }];
}

- (void)testLoadViewExist
{
    //ipo-Fixture_CompetitorName ipo-CompetitionBase
    NSString * js = @"function test2 (){var e =$('.ipo-Fixture_CompetitorName');if(e.length > 0){return 'OK';} return 'NO'}  test2()";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error)
    {
        if (error)
        {
            NSLog(@"error = %@",[error userInfo]);
        }
        else
        {
            NSLog(@"testLoadViewExist = %@",result);
            if ([[result uppercaseString] isEqualToString:@"OK"])
            {
                NSLog(@"kkkkkkkkkkkkkkk");
                [self searchMatch];
            }
            else if([[result uppercaseString] isEqualToString:@"NO"])
            {
                [self performSelector:@selector(testLoadViewExist) withObject:nil afterDelay:0.5];
            }
        }
    }];
}
@end
