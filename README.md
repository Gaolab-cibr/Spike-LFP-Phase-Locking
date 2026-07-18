# Spike-LFP Phase-Locking

MATLAB code and example data for spike–LFP phase-locking analysis accompanying the Nature Communications article “Umbrella-type stretchable electrode arrays for long-term neural recording”.

## Files

- `computeSpikeLFPPhaseLocking.m`: MATLAB analysis function.
- `example_data/`: example LFP data, timestamps, and spike timestamps.
- `example_output/`: example Excel output.

## Requirements

- MATLAB R2019b or later

## Input data

- `LFPData_4_10Hz.mat`: contains `LFPData_4_10Hz`, the LFP data filtered at 4–10 Hz.
- `LFPData_Timestamp.mat`: contains `LFPData_Timestamp`, the corresponding 1-kHz timestamps in seconds.
- `Spike_Timestamp.mat`: contains `Spike_Timestamp`, the spike timestamps from one neuron in seconds.

The LFP data and LFP timestamps must have the same length.

## Usage

```matlab
load('example_data/LFPData_4_10Hz.mat');
load('example_data/LFPData_Timestamp.mat');
load('example_data/Spike_Timestamp.mat');

results = computeSpikeLFPPhaseLocking( ...
    LFPData_4_10Hz, LFPData_Timestamp, Spike_Timestamp);
```

The function generates `LFPSpikePhaseLocking.xlsx` in the current MATLAB folder.

## Output

The `Summary` sheet contains:

- mean phase in degrees;
- length of the resultant vector;
- number of spikes;
- Rayleigh Z statistic;
- Rayleigh p value.

The `PhaseHistogram` sheet contains the spike-phase distribution in 36 bins. `Phase_Median` ranges from −175° to 175° in 10° steps.
