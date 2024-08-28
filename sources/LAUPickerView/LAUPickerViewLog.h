#ifdef DEBUG_LOG
#define Log(format, ...) NSLog(@"%@",[NSString stringWithFormat:format, ## __VA_ARGS__])
#define Logc(format, ...) printf((format "\n"), ## __VA_ARGS__)
#define PrettyLog NSLog(@"%s", __PRETTY_FUNCTION__)
#define PrettyLogc printf("%s\n", __PRETTY_FUNCTION__)
#else
#define Log(format, ...)
#define Logc(format, ...)
#define PrettyLog
#define PrettyLogc
#ifndef NS_BLOCK_ASSERTIONS // Block Assertions in Release versions
#define NS_BLOCK_ASSERTIONS
#endif
#endif
