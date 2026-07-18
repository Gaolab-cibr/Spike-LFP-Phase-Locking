function results = computeSpikeLFPPhaseLocking(LFPData_4_10Hz, LFPData_Timestamp, Spike_Timestamp)
% Compute spike-LFP phase locking from three workspace variables.
%
% Inputs:
%   LFPData_4_10Hz:    filtered LFP data
%   LFPData_Timestamp: corresponding 1-kHz timestamps in seconds
%   Spike_Timestamp:   spike timestamps in seconds

lfp = LFPData_4_10Hz(:);
lfpTime = round(LFPData_Timestamp(:) * 1000) / 1000;
spikeTime = Spike_Timestamp(:);

if numel(lfp) ~= numel(lfpTime)
    error('The LFP data and LFP timestamps must have the same length.');
end

spikeTime = spikeTime(spikeTime >= lfpTime(1) & spikeTime <= lfpTime(end));
lfpPhase = angle(hilbert(lfp));

% Assign an LFP phase to each spike using the original analysis convention.
spikePhase = nan(size(spikeTime));
for k = 1:numel(spikeTime)
    centerIndex = round((spikeTime(k) - lfpTime(1)) * 1000) + 1;
    nearby = max(1, centerIndex - 3):min(numel(lfpTime), centerIndex + 3);
    phaseIndex = nearby(abs(lfpTime(nearby) - spikeTime(k)) <= 0.001);

    if numel(phaseIndex) == 1
        spikePhase(k) = lfpPhase(phaseIndex);
    else
        firstIndex = phaseIndex(1);
        secondIndex = phaseIndex(2);
        firstPhase = lfpPhase(firstIndex);
        secondPhase = lfpPhase(secondIndex);
        if firstPhase > 0 && secondPhase < 0
            secondPhase = secondPhase + 2 * pi;
        end
        spikePhase(k) = (firstPhase * (spikeTime(k) - lfpTime(firstIndex)) + secondPhase * (lfpTime(secondIndex) - spikeTime(k))) * 1000;
        if spikePhase(k) > pi
            spikePhase(k) = spikePhase(k) - 2 * pi;
        end
    end
end

nSpikes = numel(spikePhase);
resultantVector = sum(exp(1i * spikePhase));
meanPhaseDegrees = rad2deg(angle(resultantVector));
resultantVectorLength = abs(resultantVector) / nSpikes;
rayleighZ = nSpikes * resultantVectorLength ^ 2;
rayleighP = exp(sqrt(1 + 4 * nSpikes + 4 * (nSpikes ^ 2 - (nSpikes * resultantVectorLength) ^ 2)) - (1 + 2 * nSpikes));

phaseEdges = linspace(-pi, pi, 37);
phaseCentersDegrees = rad2deg(phaseEdges(1:end-1) + diff(phaseEdges) / 2)';
wrappedSpikePhase = mod(spikePhase + pi, 2 * pi) - pi;
phaseCounts = histcounts(wrappedSpikePhase, phaseEdges)';
phaseProbability = phaseCounts / nSpikes;

summaryTable = table({'Mean phase (degrees)'; 'Length of resultant vector'; ...
    'Number of spikes'; 'Rayleigh Z'; 'Rayleigh p'},[meanPhaseDegrees; resultantVectorLength; nSpikes; rayleighZ; rayleighP],'VariableNames', {'Metric', 'Value'});
histogramTable = table(phaseCentersDegrees, phaseCounts, phaseProbability,'VariableNames', {'Phase_Median', 'SpikeCount', 'Probability'});
outputFile = 'LFPSpikePhaseLocking.xlsx';
if isfile(outputFile)
    delete(outputFile);
end
writetable(summaryTable, outputFile, 'Sheet', 'Summary');
writetable(histogramTable, outputFile, 'Sheet', 'PhaseHistogram');
results.meanPhaseDegrees = meanPhaseDegrees;
results.lengthOfResultantVector = resultantVectorLength;
results.nSpikes = nSpikes;
results.rayleighZ = rayleighZ;
results.rayleighP = rayleighP;
results.phaseCentersDegrees = phaseCentersDegrees;
results.phaseProbability = phaseProbability;
end
