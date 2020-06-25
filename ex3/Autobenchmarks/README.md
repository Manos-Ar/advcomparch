# Instructions for Running Scripts

## Prepare RUN scripts
- Change appropriately the paths: `SNIPER_EXE`, `SPEC_PINBALLS_DIR`, `OUTPUT_DIR_BASE` in: `run_sniper.sh` script
- Change appropriately the paths: `OUTPUT_DIR_BASE`, `PLOT_DIR_BASE`, `POWER_DIR_BASE`, `MCPAT_PATH` in: `run_all_power.sh` script

## Prepare PLOT scripts
- Change appropriately the paths: `OUTPUT_DIR_BASE`, `PLOT_DIR_BASE` in: `plot_all_ipc.sh`
- Change appropriately the paths: `POWER_DIR_BASE`, `PLOT_DIR_BASE` in: `plot_all_area.sh`

## Make all executable:
```
chmod +x *.sh .py
```

## Run Benchmarks
- To run for all benchmarks:
```
./run_sniper.sh
```

## Run Power stats for all Benchmarks
- Edit `Benchmarks` array according to your finished benchmarks.
- To run these benchmarks:
```
./run_all_power.sh
```

## Plot Benchmarks
### Plot for all for IPC and Total Instructions
- Edit `Benchmarks` array according to your finished benchmarks.
- Run command:
```
plot_all_ipc.sh
```
- It produces IPC and Instructions plots and a `.txt` with the percentage of total instructions for each benchmark

### Plot for Chip area and EDP
- Run command:
```
plot_all_area-EDP.sh
```
- It produces one plot for chip area (every benchmark has the same result)
