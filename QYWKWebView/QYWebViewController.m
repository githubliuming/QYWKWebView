//
//  QYWebViewController.m
//  QYWKWebView
//
//  Created by 明刘 on 2018/6/21.
//  Copyright © 2018 yoyo. All rights reserved.
//

#import "QYWebViewController.h"
#import "NCChineseConverter.h"
#import <JavaScriptCore/JavaScriptCore.h>
@interface QYWebViewController ()<UIWebViewDelegate>
{
     UIWebView * locationWebView;
}


@property(nonatomic,strong)JSContext * context;
@property(nonatomic, strong)NSString * teamA;
@property(nonatomic,strong) NSString * treamB;
@end

@implementation QYWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    locationWebView.delegate = self;
    [self.view addSubview:locationWebView];
    
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://mobile.7788365365.com/#type=InPlay;key=;ip=1;lng=2"]];
     [locationWebView loadRequest:requst];
    
    self.teamA = @"特蘭斯邁 後備隊";
    self.treamB = @"魚雷明斯克 後備隊";
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"title %@",title);
    
     self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //注入JS需要的“OC”对象
    self.context[@"OC"] = self;
    
    JSValue * function = self.context[@"ns_moblib_util.IOSAppUtility.Instance.handlers.appInitCallback"];
    self.context[@"ns_moblib_util.IOSAppUtility.Instance.handlers.appInitCallback"] = ^(void){
        
        [function callWithArguments:nil];
        
    };
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {}


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
                            "}"
                            "} return 'unfind'} postStr();",team_a,team_b,[NSString stringWithFormat:@"%@v%@直播比赛正常解析正常",team_a,team_b]];
    
    // else {alert( temp_a + '||' +  temp_b)}
    //    NSLog(@"searchCode:\n%@",searchCode);
    
//    [self.webView evaluateJavaScript:searchCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//
//        NSLog(@"result = %@",result);
//
//    }];
    NSString * res =  [locationWebView stringByEvaluatingJavaScriptFromString:searchCode];
    NSLog(@"res: %@",res);
    if([res isEqualToString:@"ok"])
    {
        [self performSelector:@selector(hidView) withObject:nil afterDelay:1.0f];
    }
}


//打开第二个页面
- (void)hidView
{
    
    //    locationWebView.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    NSString * hiddenCode = @"$('#FooterContainer,.ml1-MatchLiveSoccerModule_LocationsMenuConstrainerNarrow,.g5-HorizontalScroller_HScroll,.ipe-EventViewTitle,.v5,.MarketGrid,.ipe-MarketGrid_Classification-1,.hm-HeaderPod_Nav ,.state-LoggedOut,.hm-HeaderModule_Narrow,.hm-HeaderModule ,.ml1-ModalController_Icon,.ml1-ModalController_Icon-Summary,.ml1-ModalController_Icon,.ml1-ModalController_Icon-Table ').hide();";
    
    NSLog(@"隐藏元素\n %@",hiddenCode);
    
    NSInteger height = [[locationWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSLog(@"heightheightheightheight %d",height);
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", height];
    [locationWebView stringByEvaluatingJavaScriptFromString:javascript];
    
//    [self.webView evaluateJavaScript:hiddenCode completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//
//        [self.webView evaluateJavaScript:@"document.body.offsetHeight;" completionHandler:^(id _Nullable height, NSError * _Nullable error) {
//
//            NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", [height integerValue]];
//            [self.webView evaluateJavaScript:javascript completionHandler:^(id _Nullable resutl, NSError * _Nullable error) {
//            }];
//        }];
//    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
