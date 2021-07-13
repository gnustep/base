#import "ObjectTesting.h"
#import <Foundation/NSThread.h>

#if defined(_WIN32)
#include <process.h>
#else
#include <pthread.h>
#endif

static NSThread *threadResult = nil;

void *thread(void *ignored)
{
  threadResult = [NSThread currentThread];
  return NULL;
}

int main(void)
{
#if defined(_WIN32)
  HANDLE thr;
  thr = _beginthreadex(NULL, 0, thread, NULL, 0, NULL);
  WaitForSingleObject(thr, INFINITE);
#else
  pthread_t thr;
  pthread_create(&thr, NULL, thread, NULL);
  pthread_join(thr, NULL);
#endif
  PASS(threadResult != 0, "NSThread lazily created from native thread");
  testHopeful = YES;
  PASS((threadResult != 0) && (threadResult != [NSThread mainThread]),
    "Spawned thread is not main thread");

#if defined(_WIN32)
  thr = _beginthreadex(NULL, 0, thread, NULL, 0, NULL);
  WaitForSingleObject(thr, INFINITE);
#else
  pthread_create(&thr, NULL, thread, NULL);
  pthread_join(thr, NULL);
#endif
  PASS(threadResult != 0, "NSThread lazily created from native thread");
  PASS((threadResult != 0) && (threadResult != [NSThread mainThread]),
    "Spawned thread is not main thread");

  NSThread *t = [NSThread currentThread];
  [t setName: @"xxxtestxxx"];
  NSLog(@"Thread description is '%@'", t);
  NSRange r = [[t description] rangeOfString: @"name = xxxtestxxx"];
  PASS(r.length > 0, "thread description contains name");

  return 0;
}

