##Install scipy numpy
sudo apt-get install python-scipy
sudo apt-get install python-numpy

## Prepare PLOT scripts
- Move `plot_geometric_mean.sh`, `plot_l1.sh`, `plot_l2.sh`, `plot_tlb.sh`, `plot_prf.sh` to `/path/to/parsec-3.0/parsec_workspace`

- Make all of them executable:
```
chmod +x *.sh
### Plot for all L1 benchmarks
- Run command:

./plot_geometric_mean.sh L1

geometric_mean
### Plot for all L2 benchmarks
- Run command:
```
./plot_geometric_mean.sh L2
```

### Plot for all TLB benchmarks
- Run command:
```
./plot_geometric_mean.sh TLB
