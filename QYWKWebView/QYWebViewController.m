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
#define KLoadDataForSearchGame  @"KLoadDataForSearchGame"
#define KLoadGameSVGView    @"KWillLoadGameSVGView"
#define KLoadGameFinsh          @"KLoadGameFinsh"
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
    
    self.teamA = @"尼日利亞";
    self.treamB = @"冰島";
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"title %@",title);
    [self testLoadViewExist];
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
    
    NSString * res =  [locationWebView stringByEvaluatingJavaScriptFromString:searchCode];
    NSLog(@"res: %@",res);
    if([res isEqualToString:@"ok"])
    {
        [self testGameContextView];
    }
    else
    {
        NSLog(@"未找到比赛");
    }
}
- (void)testGameContextView
{
    NSString * js = @"function test3 (){var svg =$('.ip-MatchLiveContainer'); if(svg.length > 0){return 'OK';} return 'NO'}  test3()";
    
    NSString * result = [locationWebView stringByEvaluatingJavaScriptFromString:js];
    if ([[result uppercaseString] isEqualToString:@"OK"])
    {
        [self hidView];
    }
    else if([[result uppercaseString] isEqualToString:@"NO"])
    {
        [self performSelector:@selector(testGameContextView) withObject:nil afterDelay:1/30.f];
        
    }
}

//打开第二个页面
- (void)hidView
{
    
    //    locationWebView.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    NSString * hiddenCode = @"$('#FooterContainer,.ml1-MatchLiveSoccerModule_LocationsMenuConstrainerNarrow,.g5-HorizontalScroller_HScroll,.ipe-EventViewTitle,.v5,.MarketGrid,.ipe-MarketGrid_Classification-1,.hm-HeaderPod_Nav ,.state-LoggedOut,.hm-HeaderModule_Narrow,.hm-HeaderModule ,.ml1-ModalController_Icon,.ml1-ModalController_Icon-Summary,.ml1-ModalController_Icon,.ml1-ModalController_Icon-Table ').hide();";
    
    NSLog(@"隐藏元素\n %@",hiddenCode);
    [locationWebView stringByEvaluatingJavaScriptFromString:hiddenCode];
    NSInteger height = [[locationWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    NSLog(@"heightheightheightheight %d",height);
    NSString* javascript = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", height];
    [locationWebView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)testLoadViewExist
{
    //ipo-Fixture_CompetitorName ipo-CompetitionBase
    NSString * js = @"function test2 (){var e =$('.ipo-Fixture_CompetitorName');if(e.length > 0){return 'OK';} return 'NO'}  test2()";
    NSString * result = [locationWebView stringByEvaluatingJavaScriptFromString:js];
    if ([result isEqualToString:@"OK"])
    {
        [self searchMatch];
    }
    else
    {
        [self performSelector:@selector(testLoadViewExist) withObject:nil afterDelay:1/30.0f];
    }
}
@end
