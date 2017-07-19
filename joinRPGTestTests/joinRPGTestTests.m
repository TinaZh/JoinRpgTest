//
//  joinRPGTestTests.m
//  joinRPGTestTests
//
//  Created by Tina Zhelokova on 11.07.17.
//  Copyright © 2017 Tina Zhelokova. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ServerHelper.h"

@interface joinRPGTestTests : XCTestCase

@end

@implementation joinRPGTestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


static NSString *gameId = @"124";
static NSString *gameName = @"Русская классика";
static NSString *characterId = @"4204";
static NSString *claimId = @"1";


- (void)testAuthentification {
     NSDictionary* requestParametersDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"test@hotbox.ru", @"username", @"testtest", @"password", @"password", @"grant_type", nil];
    
    __block NSString *session;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ServerHelper postRequestFromUrl:[ServerHelper getAuthentificationUrl]
                              inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                withRequestParameters:requestParametersDict
                            onSuccess:^(id data) {
                                session =  [data objectForKey:@"access_token"];
                                NSLog(@"token = %@", session);
                                dispatch_semaphore_signal(semaphore);
                            } onError:^(NSError *serverError) {
                                XCTFail(@"Get token ERROR = %@", [serverError localizedDescription]);
                                dispatch_semaphore_signal(semaphore);
                            }];
    
    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Get token time out");
    }

    semaphore = dispatch_semaphore_create(0);
    [ServerHelper getRequestFromUrl:[ServerHelper getMyActiveProjectsUrl]
                            inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                         withHeader:[ServerHelper getAuthHeaderForToken:session]
                          onSuccess:^(id data) {
                              NSLog(@"%@", data);
                              dispatch_semaphore_signal(semaphore);
                          } onError:^(NSError *serverError) {
                              XCTFail(@"Get myProject ERROR = %@", [serverError localizedDescription]);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Get token time out");
    }
    
    //Insufficient rights error
    semaphore = dispatch_semaphore_create(0);
    [ServerHelper getRequestFromUrl:[ServerHelper getMetadataFieldsUrlForGame:gameId]
                            inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                         withHeader:[ServerHelper getAuthHeaderForToken:session]
                          onSuccess:^(id data) {
                              XCTFail(@"Receive data instead of auth error. data = %@", data);
                              dispatch_semaphore_signal(semaphore);
                          } onError:^(NSError *serverError) {
                              XCTAssert([serverError code] == 401, @"Metadata authentification error incorrect. ERROR = %@", serverError);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Metadata authentification error time out");
    }
}

- (void)testAuthentificationError {
    NSDictionary* requestParametersDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"test", @"username", @"", @"password", @"password", @"grant_type", nil];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ServerHelper postRequestFromUrl:[ServerHelper getAuthentificationUrl]
                         inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
           withRequestParameters:requestParametersDict
                       onSuccess:^(id data) {
                           XCTFail(@"Receive data instead of auth error. data = %@", data);
                           dispatch_semaphore_signal(semaphore);
                       } onError:^(NSError *serverError) {
                           XCTAssert([serverError code] == 400, @"Authentification error incorrect. ERROR = %@", serverError);
                           dispatch_semaphore_signal(semaphore);
                       }];
    
    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Get token time out");
    }
    
    semaphore = dispatch_semaphore_create(0);
    [ServerHelper getRequestFromUrl:[ServerHelper getMyActiveProjectsUrl]
                            inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                         withHeader:nil
                          onSuccess:^(id data) {
                              XCTFail(@"Receive data instead of auth error. data = %@", data);
                              dispatch_semaphore_signal(semaphore);
                          } onError:^(NSError *serverError) {
                              XCTAssert([serverError code] == 401, @"Metadata authentification error incorrect. ERROR = %@", serverError);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Metadata authentification error time out");
    }
    
    semaphore = dispatch_semaphore_create(0);
    [ServerHelper getRequestFromUrl:[ServerHelper getMetadataFieldsUrlForGame:gameId]
                         inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                        withHeader:nil
                       onSuccess:^(id data) {
                           XCTFail(@"Receive data instead of auth error. data = %@", data);
                            dispatch_semaphore_signal(semaphore);
                       } onError:^(NSError *serverError) {
                           XCTAssert([serverError code] == 401, @"Metadata authentification error incorrect. ERROR = %@", serverError);
                           dispatch_semaphore_signal(semaphore);
                       }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Metadata authentification error time out");
    }
    
    semaphore = dispatch_semaphore_create(0);
    [ServerHelper getRequestFromUrl:[ServerHelper getCharactersListUrlForGame:gameId]
                            inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                         withHeader:nil
                          onSuccess:^(id data) {
                              XCTFail(@"Receive data instead of auth error. data = %@", data);
                              dispatch_semaphore_signal(semaphore);
                          } onError:^(NSError *serverError) {
                              XCTAssert([serverError code] == 401, @"Get characters list authentification error incorrect. ERROR = %@", serverError);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Get characters list authentification error time out");
    }
    
    semaphore = dispatch_semaphore_create(0);
    [ServerHelper getRequestFromUrl:[ServerHelper getCharacterUrl: characterId forGame:gameId]
                            inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                         withHeader:nil
                          onSuccess:^(id data) {
                              XCTFail(@"Receive data instead of auth error. data = %@", data);
                              dispatch_semaphore_signal(semaphore);
                          } onError:^(NSError *serverError) {
                              XCTAssert([serverError code] == 401, @"Get characters list authentification error incorrect. ERROR = %@", serverError);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Get characters list authentification error time out");
    }
    
    semaphore = dispatch_semaphore_create(0);
    [ServerHelper getRequestFromUrl:[ServerHelper getCheckinAllClaimsUrlForGame:gameId]
                            inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                         withHeader:nil
                          onSuccess:^(id data) {
                              XCTFail(@"Receive data instead of auth error. data = %@", data);
                              dispatch_semaphore_signal(semaphore);
                          } onError:^(NSError *serverError) {
                              XCTAssert([serverError code] == 401, @"Metadata authentification error incorrect. ERROR = %@", serverError);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Metadata authentification error time out");
    }
    
    semaphore = dispatch_semaphore_create(0);
    [ServerHelper postRequestFromUrl:[ServerHelper getCheckinCheckinUrlForGame:gameId]
                            inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
               withRequestParameters:nil
                          onSuccess:^(id data) {
                              XCTFail(@"Receive data instead of auth error. data = %@", data);
                              dispatch_semaphore_signal(semaphore);
                          } onError:^(NSError *serverError) {
                              XCTAssert([serverError code] == 401, @"Get characters list authentification error incorrect. ERROR = %@", serverError);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Get characters list authentification error time out");
    }
    
    semaphore = dispatch_semaphore_create(0);
    [ServerHelper getRequestFromUrl:[ServerHelper getCheckinPrepareUrl: claimId forGame:gameId]
                            inQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                         withHeader:nil
                          onSuccess:^(id data) {
                              XCTFail(@"Receive data instead of auth error. data = %@", data);
                              dispatch_semaphore_signal(semaphore);
                          } onError:^(NSError *serverError) {
                              XCTAssert([serverError code] == 401, @"Get characters list authentification error incorrect. ERROR = %@", serverError);
                              dispatch_semaphore_signal(semaphore);
                          }];
    
    timeoutTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SERVER_WAIT_TIME * NSEC_PER_SEC));
    if (dispatch_semaphore_wait(semaphore, timeoutTime)) {
        XCTFail(@"Get characters list authentification error time out");
    }

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
