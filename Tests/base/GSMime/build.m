#if     defined(GNUSTEP_BASE_LIBRARY)
#import <Foundation/Foundation.h>
#import <GNUstepBase/GSMime.h>
#import "Testing.h"
int main(int argc,char **argv)
{
  NSAutoreleasePool   *arp = [NSAutoreleasePool new];
  NSData *data = nil;
  NSString *string = nil;
  GSMimeDocument *doc = [[GSMimeDocument alloc] init];
  NSMutableDictionary *par = [[NSMutableDictionary alloc] init];

  [par setObject: @"my/type" forKey: @"type"];
  [doc setContent: @"Hello\r\n"];
  [doc setHeader: [[GSMimeHeader alloc] initWithName: @"content-type"
  					       value: @"text/plain"
					  parameters: par]];

  [doc setHeader:
    [[GSMimeHeader alloc] initWithName: @"content-transfer-encoding"
                                 value: @"binary"
                            parameters: nil]];
				
  data = [NSData dataWithContentsOfFile: @"mime8.dat"];
  PASS([[doc rawMimeData] isEqual: data], "Can make a simple document");

  string = @"MBNA credit card account − more information about Apple Pay.";
  [doc setHeader:
    [[GSMimeHeader alloc] initWithName: @"subject"
                                 value: string
                            parameters: nil]];
  data = [doc rawMimeData];
  PASS(data != nil, "Can use non-ascii character in subject");
  [[doc rawMimeData] writeToFile: @"/tmp/xyz" atomically: NO];
  doc = [GSMimeParser documentFromData: data];
  PASS_EQUAL([[doc headerNamed: @"subject"] value], string,
   "Can restore non-ascii character in subject");

  [arp release]; arp = nil;
  return 0;
}
#else
int main(int argc,char **argv)
{
  return 0;
}
#endif
