### NO LBR

| Benchmarked on / clang versions | Baseline clang | clang.format.c (5188) | clang.tty.c       (3026) | clang.window-copy.c (5662) | clang.extsmaild.c (1781) |
| --- | --- | --- | --- | --- | --- |
| format.c | 0.907 ± 0.0008 | 0.739 ± 0.0089 | 0.739 ± 0.0074 | 0.735 ± 0.0005 | 0.737 ± 0.0061 |
| tty.c | 0.557 ± 0.0008 | 0.451 ± 0.0005 | 0.451 ± 0.0005 | 0.450 ± 0.0005 | 0.449 ± 0.0005 |
| window-copy.c | 0.880 ± 0.0008 | 0.717 ± 0.0008 | 0.718 ± 0.0005 | 0.717 ± 0.0005 | 0.715 ± 0.0008 |
| extsmaild.c | 0.251 ± 0.0005 | 0.209 ± 0.0005 | 0.209 ± 0.0005 | 0.209 ± 0.0005 | 0.209 ± 0.0005 |

The range (Mean ± CI) for each run using clang binaries overlaps significantly delta is not large enough to conclude relationship between LOC and performance.

Reason: in no lbr mode even the other formats are not giving enough information to make significant performance difference that lbr and intel-pt does?

## LBR

| Benchmarked on / clang versions | Baseline clang | clang.extsmaild.c (1781) | clang.tty.c       (3026) | clang.format.c (5188) | clang.window-copy.c (5662) |
| --- | --- | --- | --- | --- | --- |
| format.c | 0.907 ± 0.0008 | 0.736 ± 0.0082 | 0.731 ± 0.0070 | 0.725 ± 0.0093 | 0.723 ± 0.0005 |
| tty.c | 0.557 ± 0.0008 | 0.450 ± 0.0005 | 0.444 ± 0.0005 | 0.442 ± 0.0005 | 0.442 ± 0.0005 |
| window-copy.c | 0.880 ± 0.0008 | 0.716 ± 0.0008 | 0.710 ± 0.0008 | 0.705 ± 0.0008 | 0.704 ± 0.0008 |
| extsmail.c | 0.251 ± 0.0005 | 0.209 ± 0.0005 | 0.207 ± 0.0005 | 0.205 ± 0.0005 | 0.206 ± 0.0005 |

Increase in LOC profiled function trends overall in better performance with equal or deminishing returns over increasing LOC. In any case, extsmaild.c profiled clang performs worse among optimized clangs.

## Intel PT

| Run/Profile | Baseline | extsmail.c.           (1781) | tty.c         (3026) | format.c (5188) | window-copy.c.    (5662) |
| --- | --- | --- | --- | --- | --- |
| format.c | 0.907 ± 0.0008 | 0.723 ± 0.006 | 0.709 ± 0.0009 | 0.701 ± 0.009 | 0.701 ± 0.0008 |
| tty.c | 0.557 ± 0.0008 | 0.441 ± 0.0005 | 0.430 ± 0.0005 | 0.429 ± 0.0005 | 0.428 ± 0.0005 |
| window-copy.c | 0.880 ± 0.0008 | 0.705 ± 0.0008 | 0.689 ± 0.0008 | 0.684 ± 0.0008 | 0.680 ± 0.0008 |
| extsmail.c | 0.251 ± 0.0005 | 0.205 ± 0.0005 | 0.203 ± 0.0005 | 0.201 ± 0.0005 | 0.202 ± 0.0005 |

Like LBR mode, increase in LOC tends to better the performance with significantly diminishing returns over increase in clang profiled with bigger files. 

Example, look at format.c run, when compare extsmaild.c profiled clang to tty.c profiled clang the delta is 0.014 seconds while comparing tty.c profiled clang to format.c profiled clang is 0.008. And comparing clang profiled from format.c and window-copy.c, delta is neglible (in one case it becomes worse).

### **Q: Is LBR data worse than NO LBR in any of the runs (compare best of NO LBR and worst of LBR)**

extsmaild.c profiled clang gives overall the best results in NO LBR format, and worst in NO LBR format. The Mean ±  CI range overlaps significantly that we cannot say that LBR performs worse. 

### **Q: Is Intel PT data worse than LBR in any of the runs (compare best of LBR and worst of LBR)**

Similar to LBR case, the best case in LBR (window-copy.c profiled clang) and worst case in Intel PT mode (extsmaild.c profiled clang) overlaps but can’t be claimed that PT is worse. With same profiled clang(s) Intel PT performs overall better.
