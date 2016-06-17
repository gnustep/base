
#import "ObjectTesting.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSRegularExpression.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSValue.h>

@interface DegeneratePatternTest : NSObject
{
  NSRegularExpression *expression;
  NSString* input;
}
@end

@implementation DegeneratePatternTest

- (instancetype) init
{
  if (nil == (self = [super init]))
    {
      return nil;
    }
  expression =
    [[NSRegularExpression alloc] initWithPattern: @"^(([a-z])+.)+[A-Z]([a-z])+$"
                                         options: 0
                                          error: NULL];
  ASSIGN(input, @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!");
  return self;
}

- (void) runTest: (id)obj
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  [expression matchesInString: input
                      options: 0
                        range: NSMakeRange(0, [input length])];
  DESTROY(pool);
}

- (void) dealloc
{
  DESTROY(expression);
  DESTROY(input);
  [super dealloc];
}
@end


int main()
{
  NSAutoreleasePool   *arp = [NSAutoreleasePool new];
# ifdef GNUSTEP
    // Ensure that a deterministic limit is set up for this process
    NSUserDefaults *dflts = [NSUserDefaults standardUserDefaults];
    NSDictionary *domain = [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt: 1500], @"GSRegularExpressionWorkLimit", nil];
    [dflts setVolatileDomain: domain
                     forName: @"GSTestDomain"];
# endif
  id testObj = [[NSRegularExpression alloc] initWithPattern: @"^a"
                                                    options: 0
                                                      error: NULL];

  test_NSObject(@"NSRegularExpression",
                [NSArray arrayWithObject:
                  [[NSRegularExpression alloc] initWithPattern: @"^a"
                                                       options: 0
                                                         error: NULL]]);
  test_NSCopying(@"NSRegularExpression",@"NSRegularExpression",
                 [NSArray arrayWithObject:testObj],NO,NO);


  /* To test whether we correctly bail out of processing degenerate patterns,
   * we spin up a new thread and evaluate an expression there. The expectation
   * is that the thread should terminate within a few seconds.
   *
   * NOTE: Since we cannot terminate the thread in case of a failure, this
   * test should be run last.
   */
  DegeneratePatternTest *test = [DegeneratePatternTest new];
  NSThread *thread = [[NSThread alloc] initWithTarget: test
                                              selector: @selector(runTest:)
                                                object: nil];
  [thread start];
  [thread setName: @"PatternTestRunner"];
  NSDate *started = [NSDate date];
  NSRunLoop *rl = [NSRunLoop currentRunLoop];
  /* We spin the runloop for a bit while we wait for the other thread to bail
   * out */
  while ([thread isExecuting] && abs([started timeIntervalSinceNow] < 10.0f))
    {
      [rl runMode: NSDefaultRunLoopMode
       beforeDate: [NSDate dateWithTimeIntervalSinceNow: 0.01]];
    }
  PASS(NO == [thread isExecuting], "Faulty regular expression terminated");
  [arp release]; arp = nil;
  return 0;
}