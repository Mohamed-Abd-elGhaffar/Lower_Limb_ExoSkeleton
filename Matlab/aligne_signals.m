% 1. Extract the raw time and data vectors from your timeseries objects
ts1 = ankle_angle;
ts2 = ankle_angle1;
t1 = ts1.Time;  y1 = ts1.Data;
t2 = ts2.Time;  y2 = ts2.Data;

% --- THE FIX: Remove duplicate timestamps ---
% Find the unique time points and their indices
[t1_unique, idx1] = unique(t1);
y1_unique = y1(idx1);

[t2_unique, idx2] = unique(t2);
y2_unique = y2(idx2);
% --------------------------------------------

% 2. Determine a common time step (dt)
% Use the unique vectors to calculate the diff
dt1 = median(diff(t1_unique)); 
dt2 = median(diff(t2_unique));
dt_common = min(dt1, dt2); 

% 3. Create a common time vector
t_start = max(min(t1_unique), min(t2_unique));
t_end = min(max(t1_unique), max(t2_unique));
t_common = t_start : dt_common : t_end;

% 4. Interpolate both signals onto the new common time grid
% Pass the UNIQUE time and data vectors into interp1
y1_interp = interp1(t1_unique, y1_unique, t_common, 'linear');
y2_interp = interp1(t2_unique, y2_unique, t_common, 'linear');

% --- CRITICAL STEP: Mean-center the data ---
y1_interp = y1_interp - mean(y1_interp);
y2_interp = y2_interp - mean(y2_interp);

% 5. Perform Cross-Correlation
[corr_values, lags] = xcorr(y1_interp, y2_interp);

% 6. Find the peak of the correlation
[~, max_idx] = max(abs(corr_values));
best_lag_in_samples = lags(max_idx);

% 7. Convert the sample lag back into an actual TIME estimate
time_shift_estimate = best_lag_in_samples * dt_common;
fprintf('The estimated time shift is: %f seconds\n', time_shift_estimate);

% If time_shift_estimate is positive, ts2 is delayed (shifted right) relative to ts1.
% If negative, ts2 is ahead (shifted left) relative to ts1.