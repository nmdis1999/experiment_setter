### NO LBR

| Benchmarked on / clang versions | Baseline clang | clang.format.c (5188) | clang.tty.c       (3026) | clang.window-copy.c (5662) | clang.extsmaild.c (1781) |
| --- | --- | --- | --- | --- | --- |
| format.c | 0.907 ± 0.0008 | 0.739 ± 0.0089 | 0.739 ± 0.0074 | 0.735 ± 0.0005 | 0.737 ± 0.0061 |
| tty.c | 0.557 ± 0.0008 | 0.451 ± 0.0005 | 0.451 ± 0.0005 | 0.450 ± 0.0005 | 0.449 ± 0.0005 |
| window-copy.c | 0.880 ± 0.0008 | 0.717 ± 0.0008 | 0.718 ± 0.0005 | 0.717 ± 0.0005 | 0.715 ± 0.0008 |
| extsmaild.c | 0.251 ± 0.0005 | 0.209 ± 0.0005 | 0.209 ± 0.0005 | 0.209 ± 0.0005 | 0.209 ± 0.0005 |

The range (Mean ± CI) for each run using clang binaries overlaps significantly
delta is not large enough to conclude relationship between LOC and performance.

Reason: in no lbr mode even the other formats are not giving enough information
to make significant performance difference that lbr and intel-pt does?

## LBR

| Benchmarked on / clang versions | Baseline clang | clang.extsmaild.c (1781) | clang.tty.c       (3026) | clang.format.c (5188) | clang.window-copy.c (5662) |
| --- | --- | --- | --- | --- | --- |
| format.c | 0.907 ± 0.0008 | 0.736 ± 0.0082 | 0.731 ± 0.0070 | 0.725 ± 0.0093 | 0.723 ± 0.0005 |
| tty.c | 0.557 ± 0.0008 | 0.450 ± 0.0005 | 0.444 ± 0.0005 | 0.442 ± 0.0005 | 0.442 ± 0.0005 |
| window-copy.c | 0.880 ± 0.0008 | 0.716 ± 0.0008 | 0.710 ± 0.0008 | 0.705 ± 0.0008 | 0.704 ± 0.0008 |
| extsmail.c | 0.251 ± 0.0005 | 0.209 ± 0.0005 | 0.207 ± 0.0005 | 0.205 ± 0.0005 | 0.206 ± 0.0005 |

Increase in LOC profiled function trends overall in better performance with
equal or deminishing returns over increasing LOC. In any case, extsmaild.c
profiled clang performs worse among optimized clangs.

## Intel PT

| Run/Profile | Baseline | extsmail.c.           (1781) | tty.c         (3026) | format.c (5188) | window-copy.c.    (5662) |
| --- | --- | --- | --- | --- | --- |
| format.c | 0.907 ± 0.0008 | 0.723 ± 0.006 | 0.709 ± 0.0009 | 0.701 ± 0.009 | 0.701 ± 0.0008 |
| tty.c | 0.557 ± 0.0008 | 0.441 ± 0.0005 | 0.430 ± 0.0005 | 0.429 ± 0.0005 | 0.428 ± 0.0005 |
| window-copy.c | 0.880 ± 0.0008 | 0.705 ± 0.0008 | 0.689 ± 0.0008 | 0.684 ± 0.0008 | 0.680 ± 0.0008 |
| extsmail.c | 0.251 ± 0.0005 | 0.205 ± 0.0005 | 0.203 ± 0.0005 | 0.201 ± 0.0005 | 0.202 ± 0.0005 |

Like LBR mode, increase in LOC tends to better the performance with
significantly diminishing returns over increase in clang profiled with bigger
files. 

Example, look at format.c run, when compare extsmaild.c profiled clang to tty.c
profiled clang the delta is 0.014 seconds while comparing tty.c profiled clang
to format.c profiled clang is 0.008. And comparing clang profiled from format.c
and window-copy.c, delta is neglible (in one case it becomes worse).

### **Q: Is LBR data worse than NO LBR in any of the runs (compare best of NO LBR and worst of LBR)**

extsmaild.c profiled clang gives overall the best results in NO LBR format, and
worst in NO LBR format. The Mean ±  CI range overlaps significantly that we
cannot say that LBR performs worse. 

### **Q: Is Intel PT data worse than LBR in any of the runs (compare best of LBR and worst of LBR)**

Similar to LBR case, the best case in LBR (window-copy.c profiled clang) and
worst case in Intel PT mode (extsmaild.c profiled clang) overlaps but can’t be
claimed that PT is worse. With same profiled clang(s) Intel PT performs overall
better.

### **Number of functions executed by clang versions(row headers) during file compilations (column headers)**

| binaries / files | format.c | tty.c | window-copy.c  | extsmaild.c
| --- | --- | --- | --- | --- |
| clang-16.nolbr.format | 15487 | 14740 | 15858 | 14862 | 
| clang-16.nolbr.tty | 15494 | 14747 | 15865 | 14869 |
| clang-16.nolbr.window-copy | 15486 | 14738 | 15857 | 14860 |  
| clang-16.nolbr.exts | 15497 | 14751 | 15868 | 14871 |  
| clang-16.lbr.format | 21761 | 20856 | 22056 | 20889 | 
| clang-16.lbr.tty | 20399 | 19622 | 20780 | 19622 |
| clang-16.lbr.window-copy | 21671 | 20800 | 22012 | 20799 |
| clang-16.lbr.exts | 18631 | 17847 | 19003 | 17964 | 
| clang-16.pt.format. | 26062 | 24775 | 26223 | 24711 | 
| clang-16.pt.tty | 24858 | 23878 | 25141 | 23694 | 
| clang-16.pt.window-copy | 25973 | 24837 | 26335 | 24713 | 
| clang-16.pt.exts | 23253 | 22301 | 23547 | 22387 |

### **Comparing clang versions obtained from aggregating LBR profiles running _n_ times on a file with clang obtained from Intel PT mode profile running 1 time on the same file**

<figure>
    <img src="experiment_setter/plot_graphs/png_files/line_chart.extsmaild.png" alt="Line chart">
    <figcaption>In figure above, the x-axis is versions of clang (obtained with
    profile captured during file’s compilation (i.e clang.exts is clang
    optimized with llvm-bolt after gathering profile during extsmaild.c file
    compilation). The y-axis is the mean values. the line (-.) is clang
    aggregated with number of profiles (compiling the same file). And the
    shaded region is 99% confidence interval.</figcaption> 
</figure>


