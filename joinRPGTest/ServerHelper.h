#import <Foundation/Foundation.h>

#define SERVER_WAIT_TIME 100.0

extern NSString * const kBaseServerUrl;
extern NSString * const kAuthentificationUrlFormat;
extern NSString * const kCharactersListUrlFormat;
extern NSString * const kCharacterDataUrlFormat;
extern NSString * const kMetadataFieldsUrlFormat;
extern NSString * const kCheckinAllClaimsUrlFormat;
extern NSString * const kCheckinPrepareUrlFormat;
extern NSString * const kCheckinCheckinUrlFormat;
extern NSString * const kMyActiveProjectsUrlFormat;


@interface ServerHelper : NSObject

+ (NSString *) getAuthentificationUrl;
+ (NSString *) getCharactersListUrlForGame: (NSString *) gameId;
+ (NSString *) getCharacterUrl: (NSString *) characterId forGame: (NSString *) gameId;
+ (NSString *) getMetadataFieldsUrlForGame: (NSString *) gameId;
+ (NSString *) getMyActiveProjectsUrl;
+ (NSString *) getCheckinAllClaimsUrlForGame: (NSString *) gameId;
+ (NSString *) getCheckinPrepareUrl: (NSString *) claimId forGame: (NSString *) gameId;
+ (NSString *) getCheckinCheckinUrlForGame: (NSString *) gameId;

+ (NSDictionary *) getAuthHeaderForToken: (NSString *) token;


+ (void) getDataFromUrl:(NSString *) urlString withRequestParameters: (NSDictionary *)requestParametersDict
              onSuccess: (void (^)(id))onSuccess
                onError:(void (^)(NSError*))onError;

+ (void) postRequestFromUrl:(NSString *) urlString
                inQueue: (dispatch_queue_t) queue
  withRequestParameters: (NSDictionary *)requestParametersDict
              onSuccess: (void (^)(id))onSuccess
                onError:(void (^)(NSError*))onError;

+(void) getRequestFromUrl: (NSString *) urlString
                  inQueue: (dispatch_queue_t) queue
               withHeader: (NSDictionary *)headersDict
                onSuccess: (void (^)(id))onSuccess
                  onError:(void (^)(NSError*))onError;

@end
