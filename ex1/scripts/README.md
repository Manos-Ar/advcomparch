# Instructions for Running Scripts

## Change cache hit/miss cycles on `cache.h` and `tlb.h`
You have to change the values to match the given ones on the assignment
- In `/path/to/advcomparch-2019-2020-ex1-helpcode/pintool/cache.h` change the following lines:
```
207:  UINT32 l1HitLatency = 1, UINT32 l2HitLatency = 15,
208:  UINT32 l2MissLatency = 250);
```
- In `/path/to/advcomparch-2019-2020-ex1-helpcode/pintool/tlb.h` change the following lines:
```
 163:  UINT32 HitLatency = 0, UINT32 MissLatency = 100);
```
- Recompile the pintool:
```
cd /path/to/advcomparch-2019-2020-ex1-helpcode/pintool/
make clean; make
```

## Prepare RUN and PLOT scripts
- Change appropriately the paths: `PARSEC_PATH`, `PIN_EXE`, `PIN_TOOL`  in every run script: `run_l1`, `run_l2`, `run_tlb`, `run_prf`,

- Move `run_l1.sh`, `run_l2.sh`, `run_tlb.sh`, `run_prf` to `/path/to/parsec-3.0/parsec_workspace`

- Move `plot_all_caches.sh`, `plot_l1.sh`, `plot_l2.sh`, `plot_tlb.sh`, `plot_prf.sh` to `/path/to/parsec-3.0/parsec_workspace`

- Make all of them executable:
```
chmod +x *.sh
```

### Run for all L1 Benchmarks
- To run all benchmarks for L1 run:
```
./run_l1.sh
```

### Run for all L2 Benchmarks
- To run all benchmarks for L2 run:
```
./run_l2.sh
```

### Run for all TLB Benchmarks
- To run all benchmarks for TLB run:
```
./run_tlb.sh
```


### Plot for all L1 benchmarks
- Run command:
```
./plot_all_caches.sh L1
```

### Plot for all L2 benchmarks
- Run command:
```
./plot_all_caches.sh L2
```

### Plot for all TLB benchmarks
- Run command:
```
./plot_all_caches.sh TLB
```


## Prepare for Prefetching
In order to enable prefetching in L2 we must modify the code in `cache.h` file, to do that:
- Copy `cache-prf.h` file to `/path/to/advcomparch-2019-2020-ex1-helpcode/pintool/` and replace the default `cache.h`

or with one command:

```
cp cache-prf.h /path/to/advcomparch-2019-2020-ex1-helpcode/pintool/cache.h
```
- Recompile the pintool:
```
cd /path/to/advcomparch-2019-2020-ex1-helpcode/pintool/
make clean; make
```

### Run Prefetching for all Benchmarks
- To run all benchmarks for Prefetching run:
```
./run_prf.sh
```

### Plot Prefetching for all benchmarks
- Run command:
```
./plot_all_caches.sh PRF
```

## Disable Prefetching
In order to disable prefetching in L2 we must replace with the original `cache.h` file, which is `cache-og.h`:
- Copy `cache-og.h` file to `/path/to/advcomparch-2019-2020-ex1-helpcode/pintool/` and replace the previous `cache.h`

or with one command:

```
cp cache-og.h /path/to/advcomparch-2019-2020-ex1-helpcode/pintool/cache.h
```
- Recompile the pintool:
```
cd /path/to/advcomparch-2019-2020-ex1-helpcode/pintool/
make clean; make
```
