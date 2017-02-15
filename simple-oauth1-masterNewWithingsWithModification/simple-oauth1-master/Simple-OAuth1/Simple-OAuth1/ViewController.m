//
//  ViewController.m
//  Simple-OAuth1
//
//  Created by Christian Hansen on 02/12/12.
//  Copyright (c) 2012 Christian-Hansen. All rights reserved.
//

#import "ViewController.h"
#import "OAuth1Controller.h"
#import "LoginWebViewController.h"

@interface ViewController ()

@property (nonatomic, strong) OAuth1Controller *oauth1Controller;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)loginTapped
{
    LoginWebViewController *loginWebViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
    
    [self presentViewController:loginWebViewController
                       animated:YES
                     completion:^{
                          
                         [self.oauth1Controller loginWithWebView:loginWebViewController.webView completion:^(NSDictionary *oauthTokens, NSError *error) {
                            
                             if (!error) {
                                
                                 // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
                                  NSLog(@"self.oauthToken=%@,self.oauthTokenSecret",oauthTokens);
                                 self.oauthToken = oauthTokens[@"oauth_token"];
                                 self.oauthTokenSecret = oauthTokens[@"oauth_token_secret"];
                                 userId=oauthTokens[@"userid"];
                                 self.accessTokenLabel.text = self.oauthToken;
                                 self.accessTokenSecretLabel.text = self.oauthTokenSecret;
                                

                             }
                             else
                             {
                                 NSLog(@"Error authenticating: %@", error.localizedDescription);
                             }
                             [self dismissViewControllerAnimated:YES completion: ^{
                                 self.oauth1Controller = nil;
                             }];
                         }];
                     }];
}


- (IBAction)logoutTapped
{
    // Clear cookies so no session cookies can be used for the UIWebview 
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if (cookie.isSecure) {
            [storage deleteCookie:cookie];
        }
    }
    
    // Clear tokens from instance variables
    self.oauthToken = nil;
    self.oauthTokenSecret = nil;
    
    // Clear textfields
    self.accessTokenLabel.text = self.oauthToken;
    self.accessTokenSecretLabel.text = self.oauthTokenSecret;
    self.responseTextView.text = nil;
}

- (OAuth1Controller *)oauth1Controller
{
    if (_oauth1Controller == nil) {
        _oauth1Controller = [[OAuth1Controller alloc] init];
    }
    return _oauth1Controller;
}


-(void)getUserDataFromWithings:(NSString*)deviceType{
    deviceType=@"1";//4,16,1,0
       // NSLog(@"UserId %@",userId);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //[appDel loaderMethod];
    [dict setObject:@"getmeas" forKey:@"action"];
    [dict setObject:userId forKey:@"userid"];
    [dict setObject:deviceType forKey:@"devtype"];
    [dict setObject:@"500" forKey:@"limit"];
    // [dict setObject:@"1" forKey:@"meastype"];
    
    /////////
    
    //  NSString *lastUpdate=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    [dict setObject:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]] forKey:@"enddate"];
       /////////////////
    NSLog(@"self.oauthToken=%@,self.oauthTokenSecret=%@",self.oauthToken,self.oauthTokenSecret);
    NSURLRequest *request =
    [OAuth1Controller preparedRequestForPath:@"measure"
                                  parameters:dict
                                  HTTPmethod:@"GET"
                                  oauthToken:self.oauthToken
                                 oauthSecret:self.oauthTokenSecret];
    
    
    NSLog(@"RRRRR %@",request.URL);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
        
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             
             if ([[greeting valueForKey:@"status"] intValue]==0) {
                 
                 if ([[[greeting valueForKey:@"body"] valueForKey:@"measuregrps"] count]>0) {
                     
                     
                     
                     
                     
                    
                 }else{
                     UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Sync failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                 }
                
             }
         }
     }];
}

-(IBAction)getActivity:(id)sender{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //[dict setObject:CALL_BACK_URL forKey:@"oauth_callback"];
    [dict setObject:@"getactivity" forKey:@"action"];
    [dict setObject:userId forKey:@"userid"];
    
    NSDateFormatter *dtfrm = [[NSDateFormatter alloc] init];
    [dtfrm setDateFormat:@"yyyy-MM-dd"];
   
    [dict setObject:@"1970-01-01" forKey:@"startdateymd"];
    [dict setObject:@"2015-03-19" forKey:@"enddateymd"];
    /*
    if (activityMetricLastUpdate==0) {
        [dict setObject:[NSString stringWithFormat:@"%@",[dtfrm stringFromDate:tempDate]] forKey:@"enddateymd"];
    }else{
        [dict setObject:[NSString stringWithFormat:@"%@",[dtfrm stringFromDate:date]] forKey:@"startdateymd"];
        [dict setObject:[NSString stringWithFormat:@"%@",[dtfrm stringFromDate:tempDate]] forKey:@"enddateymd"];
    }
    */
     NSLog(@"self.oauthToken=%@,self.oauthTokenSecret=%@",self.oauthToken,self.oauthTokenSecret);
    NSURLRequest *request =
    [OAuth1Controller preparedRequestForPath:@"v2/measure"
                                  parameters:dict
                                  HTTPmethod:@"GET"
                                  oauthToken:self.oauthToken
                                 oauthSecret:self.oauthTokenSecret];
    
    
    NSLog(@"RRRRR %@",request.URL);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             NSLog(@"Activity MMMMMMMM %@===",greeting);
             if ([[greeting valueForKey:@"status"] intValue]==0) {
                 
                 if ([[[greeting valueForKey:@"body"] valueForKey:@"activities"] count] >0) {
                     
                     // [tempDictionary setObject:deviceType forKey:@"device_type"];
                     //[self bodyDataSending:tempDictionary];
                     
                    
                 }else{
                     UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Cloudmetrx" message:@"Sync failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alert show];
                     
                 }
                 //NSLog(@"Activity MMMMMMMM %@===",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                 
                 
                 
                 // self.greetingId.text = [[greeting objectForKey:@"id"] stringValue];
                 // self.greetingContent.text = [greeting objectForKey:@"content"];
             }
         }
     }];
}




-(IBAction)getNew:(id)sender{
    [self getActivity:nil];
    
/*
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //[dict setObject:CALL_BACK_URL forKey:@"oauth_callback"];
    [dict setObject:@"getbyuserid" forKey:@"action"];
    [dict setObject:userId forKey:@"userid"];
    //[dict setObject:userId forKey:@"userid"];
    //[dict setObject:WITHINGS_OAUTH_KEY forKey:@"oauth_consumer_key"];
    //[dict setObject:token forKey:@"oauth_token"];
    //[dict setObject:tokenSecret forKey:@"oauth_token_secret"];
    NSLog(@"self.oauthToken=%@,self.oauthTokenSecret=%@",self.oauthToken,self.oauthTokenSecret);
    NSURLRequest *request =
    [OAuth1Controller preparedRequestForPath:@"user"
                                  parameters:dict
                                  HTTPmethod:@"GET"
                                  oauthToken:self.oauthToken
                                 oauthSecret:self.oauthTokenSecret];
    
    
   // [TDOAuth URLRequestForPath:@"/measure?action=getmeas&devtype=1" GETParameters:dict host:@"wbsapi.withings.net" consumerKey:@"" consumerSecret:@"" accessToken:accessToken tokenSecret:accessTokenSecret];
    
    //  NSURLRequest *request = [TDOAuth URLRequestForPath:[NSString stringWithFormat:@"/user" ] GETParameters:dict host:@"wbsapi.withings.net" consumerKey:WITHINGS_OAUTH_KEY consumerSecret:WITHINGS_OAUTH_SECRET accessToken:accessToken tokenSecret:accessTokenSecret];
    // *request = [NSURLRequest requestWithURL:url];
    
    // [request setValue:WITHINGS_OAUTH_KEY forKey:@"oauth_consumer_key"];
    // [request setValue:token forKey:@"oauth_token"];
    //[request setValue:tokenSecret forKey:@"oauth_token_secret"];
    NSLog(@"RRRRR %@",request.URL);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             NSLog(@"HHHHHH %@===",greeting);
             // self.greetingId.text = [[greeting objectForKey:@"id"] stringValue];
             // self.greetingContent.text = [greeting objectForKey:@"content"];
         }
     }];
    */
}
- (IBAction)testGETRequest
{
    // Tumblr GET Request
//    NSString *path = @"blog/chrhansen.tumblr.com/info";                                       // Insert your Tumblr name here
//    NSDictionary *parameters = @{@"api_key" : @"The CONSUMER_KEY from OAuth1Controller.m"};   // Insert your Tumblr API-key/CONSUMER_KEY here
    
    
    // LinkedIn GET Request
    NSString *path = @"people/~";
    NSDictionary *parameters = @{@"format" : @"json"};
    
    
    // Build authorized request based on path, parameters, tokens, timestamp etc.
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path
                                                                  parameters:parameters
                                                                  HTTPmethod:@"GET"
                                                                  oauthToken:self.oauthToken
                                                                 oauthSecret:self.oauthTokenSecret];
    
    // Send the request and log response when received
    [NSURLConnection sendAsynchronousRequest:preparedRequest
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   self.responseTextView.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   if (error) NSLog(@"Error in API request: %@", error.localizedDescription);
                               });
                           }];
}


- (IBAction)testPOSTRequest
{
    // Tumblr POST Request
    NSString *path = @"blog/YOUR_TUMBLR_NAME.tumblr.com/post";            // set your Tumblr name here
    NSDictionary *parameters = @{@"type"  : @"text",
                                 @"title" : @"Simple OAuth1.0a for iOS by Christian Hansen",
                                 @"body"  : @"https://github.com/Christian-Hansen/simple-oauth1"};
    
    // LinkedIn POST Request
    // Not implemented, see http://developer.linkedin.com/
    
    // Build authorized request based on path, parameters, tokens, timestamp etc.
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path
                                                                  parameters:parameters
                                                                  HTTPmethod:@"POST"
                                                                  oauthToken:self.oauthToken
                                                                 oauthSecret:self.oauthTokenSecret];
    
    // Send the request and when received show the response in the text view
    [NSURLConnection sendAsynchronousRequest:preparedRequest
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   self.responseTextView.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   if (error) NSLog(@"Error in API request: %@", error.localizedDescription);
                               });
                           }];
}

@end
