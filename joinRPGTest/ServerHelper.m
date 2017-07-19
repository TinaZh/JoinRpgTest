#import "ServerHelper.h"

NSString * const kBaseServerUrl = @"http://dev.joinrpg.ru";
NSString * const kMyActiveProjectsUrlFormat = @"%@/x-api/me/projects/active"; //GET

NSString * const kAuthentificationUrlFormat = @"%@/x-api/token"; //POST
NSString * const kCharactersListUrlFormat = @"%@/x-game-api/%@/characters/"; //GET
NSString * const kCharacterDataUrlFormat = @"%@/x-game-api/%@/characters/%@/"; //GET
NSString * const kMetadataFieldsUrlFormat = @"%@/x-game-api/%@/metadata/fields"; //GET

NSString * const kCheckinAllClaimsUrlFormat = @"%@/x-game-api/%@/checkin/allclaims"; //GET
NSString * const kCheckinPrepareUrlFormat = @"%@/x-game-api/%@/checkin/%@/prepare"; //GET
NSString * const kCheckinCheckinUrlFormat = @"%@/x-game-api/%@/checkin/checkin"; //POST

@implementation ServerHelper

+ (NSString *) getAuthentificationUrl{
    return [NSString stringWithFormat:kAuthentificationUrlFormat, kBaseServerUrl ];
}

+ (NSString *) getMyActiveProjectsUrl{
    return [NSString stringWithFormat:kMyActiveProjectsUrlFormat, kBaseServerUrl];
}

+ (NSString *) getCharactersListUrlForGame: (NSString *) gameId{
    return [NSString stringWithFormat:kCharactersListUrlFormat, kBaseServerUrl, gameId ];
}

+ (NSString *) getCharacterUrl: (NSString *) characterId forGame: (NSString *) gameId{
    return [NSString stringWithFormat:kCharacterDataUrlFormat, kBaseServerUrl, gameId, characterId];
}

+ (NSString *) getMetadataFieldsUrlForGame: (NSString *) gameId{
    return [NSString stringWithFormat:kMetadataFieldsUrlFormat, kBaseServerUrl, gameId];
}

+ (NSString *) getCheckinAllClaimsUrlForGame: (NSString *) gameId{
    return [NSString stringWithFormat:kCheckinAllClaimsUrlFormat, kBaseServerUrl, gameId];
}

+ (NSString *) getCheckinPrepareUrl: (NSString *) claimId forGame: (NSString *) gameId{
    return [NSString stringWithFormat:kCheckinPrepareUrlFormat, kBaseServerUrl, gameId, claimId];
}

+ (NSString *) getCheckinCheckinUrlForGame: (NSString *) gameId{
    return [NSString stringWithFormat:kCheckinCheckinUrlFormat, kBaseServerUrl, gameId];
}

+ (NSDictionary *) getAuthHeaderForToken: (NSString *) token{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSString stringWithFormat:@"Bearer %@",token] forKey:@"Authorization"];
    return dict;
}

+ (NSString *) getParametersAsStringFrom:(NSDictionary *) paramSetDict{
    NSMutableArray* parametersArray = [NSMutableArray array];
    [paramSetDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:NSString.class] || [obj isKindOfClass:NSNumber.class]){
            [parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        } else if ([obj isKindOfClass:NSArray.class]){
            //example timekillers=1&timekillers=5
            NSString *str = [NSString stringWithFormat:@"&%@=", key];
            [parametersArray addObject:[NSString stringWithFormat:@"%@=%@", key, [obj componentsJoinedByString:str]]];

        }
    }];
    NSString* parameterString = [parametersArray componentsJoinedByString:@"&"];
    return parameterString;
}

+(void) getRequestFromUrl: (NSString *) urlString
                  inQueue: (dispatch_queue_t) queue
               withHeader: (NSDictionary *)headersDict
                onSuccess: (void (^)(id))onSuccess
                  onError:(void (^)(NSError*))onError{
    
    NSLog(@"url: %@ \n headers: %@", urlString, headersDict);

    NSURL * url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = headersDict;
    
    NSURLSessionDataTask * dataTask = [[NSURLSession sessionWithConfiguration:sessionConfiguration] dataTaskWithURL:url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        [self processResponseWithData:data response:response error:error inQueue:queue onSuccess:onSuccess onError:onError];
                                                    }];
    [dataTask setTaskDescription:urlString];
    [dataTask resume];
    
}

+ (void) getDataFromUrl:(NSString *) urlString withRequestParameters: (NSDictionary *)requestParametersDict
              onSuccess: (void (^)(id))onSuccess
                onError:(void (^)(NSError*))onError{
    return [self postRequestFromUrl:urlString inQueue:dispatch_get_main_queue() withRequestParameters:requestParametersDict onSuccess:onSuccess onError:onError];
  
}


+ (void) postRequestFromUrl:(NSString *) urlString inQueue: (dispatch_queue_t) queue
  withRequestParameters: (NSDictionary *)requestParametersDict
              onSuccess: (void (^)(id))onSuccess
                onError:(void (^)(NSError*))onError{


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    
    request.HTTPBody =[[self getParametersAsStringFrom: requestParametersDict]  dataUsingEncoding:NSUTF8StringEncoding];;

    NSLog(@"url: %@ \n request: %@", urlString, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);

    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = [NSDictionary dictionaryWithObjectsAndKeys: @"application/json", @"Accept", @"application/x-www-form-urlencoded", @"Content-Type", nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
                    

    NSURLSessionDataTask *downloadTask = [session
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              [self processResponseWithData:data response:response error:error inQueue:queue onSuccess:onSuccess onError:onError];
                                          }];
    [downloadTask setTaskDescription:urlString];
    [downloadTask resume];
}

+ (NSError *) createErrorWithArray:(NSArray *)array code: (NSInteger) code{
    if(!array){
        array = @[@"Empty error array"];
    }
    NSDictionary *details = [NSDictionary dictionaryWithObject:array forKey:NSLocalizedRecoveryOptionsErrorKey];
    NSError *error = [NSError errorWithDomain:@"JoinRPGServerError" code:code userInfo:details];
    NSLog(@"%@", [error description]);
    return error;
}

+ (NSError *) createErrorWithText:(NSString *)text code: (NSInteger) code{
    if(!text) {
        text = @"Empty error message";
    }
    NSDictionary *details = [NSDictionary dictionaryWithObject:text forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"JoinRPGServerError" code:code userInfo:details];
    NSLog(@"%@", [error description]);
    return error;
}

+ (void) processResponseWithData: (NSData *) data
                        response: (NSURLResponse *)response
                           error: (NSError *)error
                         inQueue: (dispatch_queue_t) queue
                       onSuccess: (void (^)(id))onSuccess
                         onError:(void (^)(NSError*))onError{
    if (!data || error != nil) {
        NSLog(@"JoinRPG server ERROR: Connection failed with error = %@", error);
        dispatch_async(queue, ^{
            onError(error);
        });
        return;
    }
    
    if ([response respondsToSelector:@selector(statusCode)]) {
        //NSLog(@"JoinRPG server ERROR: statusCode = %ld", (long)[(NSHTTPURLResponse *) response statusCode]);
        if ([(NSHTTPURLResponse *) response statusCode] != 200) {
            NSInteger errorCode = (long)[(NSHTTPURLResponse *) response statusCode];
            NSError *statusError = [self createErrorWithText:
                                    [NSString stringWithFormat: @"JoinRPG server ERROR: statusCode = %ld", errorCode]
                                                        code:errorCode];
            dispatch_async(queue, ^{
                onError(statusError);
            });
            return;
        }
    }
    
    NSError *parseJsonError = nil;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments error:&parseJsonError];
    if (!parseJsonError) {
        NSLog(@"json data = %@", responseJSON);
            id data = responseJSON;
            dispatch_async(queue, ^{
                onSuccess(data);
            });
        
    } else {
        NSError *statusError = [self createErrorWithText:
                                [NSString stringWithFormat: @"Parse json ERROR = %@", parseJsonError] code:1];
        dispatch_async(queue, ^{
            onError(statusError);
        });
    }
}

@end
