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
@interface ViewController ()<WKUIDelegate, WKNavigationDelegate,WKScriptMessageHandler>
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) WKNavigation *navigation;

@property(nonatomic, strong)NSString * teamA;
@property(nonatomic,strong) NSString * treamB;
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
    
    self.teamA = @"卡芬堡";
    self.treamB = @"維迪奧頓FC";

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
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    // decisionHandler(WKNavigationActionPolicyCancel);
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
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
}
//// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    NSLog(@"网页完全加载好");
//    [self searchMatch];
    [self performSelector:@selector(searchMatch) withObject:nil afterDelay:10.0f];
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
    
    NSLog(@"receive script message %@",[message description]);
}
#pragma mark -配置webConfig
- (WKWebViewConfiguration *)webConfiguration
{
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    config.preferences = [[WKPreferences alloc] init];
    config.processPool = [[WKProcessPool alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"hello work"];
    [self addHelloWorldAlertScript:config.userContentController];
    return config;
}

- (void)addHelloWorldAlertScript:(WKUserContentController *)userContentController
{
    if (userContentController)
    {
        WKUserScript * userScript = [[WKUserScript alloc] initWithSource:@"alert('hello world')" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        [userContentController addUserScript:userScript];
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
                            "res='ok';"
                            "return res;"
                            "} else {alert( temp_a + '||' +  temp_b)}"
                            "}} postStr();",team_a,team_b,[NSString stringWithFormat:@"%@v%@直播比赛正常解析正常",team_a,team_b]];
    
    
//    NSLog(@"searchCode:\n%@",searchCode);
    
    [self.webView evaluateJavaScript:searchCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        NSLog(@"result = %@",result);
        [self hidView];
    }];
//    NSLog(@"res: %@",res);
//    if([res isEqualToString:@"ok"])
//    {
    
//        [self performSelector:@selector(hidView) withObject:nil afterDelay:5.0f];
//    }
    
    
    
}


- (void)hidView
{
    
//    locationWebView.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    NSString * hiddenCode = @"$('#FooterContainer,.ml1-MatchLiveSoccerModule_LocationsMenuConstrainerNarrow,.g5-HorizontalScroller_HScroll,.ipe-EventViewTitle,.v5,.MarketGrid,.ipe-MarketGrid_Classification-1,.hm-HeaderPod_Nav ,.state-LoggedOut,.hm-HeaderModule_Narrow,.hm-HeaderModule ,.ml1-ModalController_Icon,.ml1-ModalController_Icon-Summary,.ml1-ModalController_Icon,.ml1-ModalController_Icon-Table ').hide();";
    
    NSLog(@"隐藏元素\n %@",hiddenCode);
    
    [self.webView evaluateJavaScript:hiddenCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        [self.webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id _Nullable height, NSError * _Nullable error) {
            
                NSLog(@"heightheightheightheight %d",[height integerValue]);
                NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", [height integerValue]];
//                [locationWebView stringByEvaluatingJavaScriptFromString:javascript];
            [self.webView evaluateJavaScript:javascript completionHandler:^(id _Nullable resutl, NSError * _Nullable error) {
                
                
            }];
        }];
    }];
//    [locationWebView stringByEvaluatingJavaScriptFromString:hiddenCode];
    
    //向上移动球场
//    NSInteger height = [[locationWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
//    NSLog(@"heightheightheightheight %d",height);
//    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", height];
//    [locationWebView stringByEvaluatingJavaScriptFromString:javascript];
//
//    [_loadingView removeFromSuperview];
    
}
@end
