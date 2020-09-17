

how to reproduce:

```
swift build

# start utility
.build/debug/BrowserBridgeConsole
```

then in a different terminal session:

```
sudo log stream -p BrowserBridgeConsole --predicate "messageType == 16"
```

then open TestEcho.html in any browser.


expected result:
no errors are logged


got result:
2020-09-17 19:42:31.550830+0200 0x2571a9   Error       0x0                  24682  0    BrowserBridgeConsole: (libnetwork.dylib) [com.apple.network:] __nw_frame_claim Claiming bytes failed because start (18) is beyond end (0 - 0)


