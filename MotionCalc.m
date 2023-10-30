% MotionCalc.m
% Inputs: 
% (1) Demeaned motion file from volume registration
% (2) Right hand force trace (downsampled, normalized, demeaned, pre-HRF convolution)
% (3) Left hand force trace (downsampled, normalized, demeaned, pre-HRF convolution)
%
% Outputs:
% (1) Average FD
% (2) Percent censored volumes at FD > 0.5
% (3) Correlation of force trace with X-direction motion

function [FDavg, censorPer, Xcorr] = MotionCalc(motion,rForce,lForce)

%% Calculate FD
% Extract motion parameters
y_deg = motion(:,1);
p_deg = motion(:,2);
r_deg = motion(:,3);
z = motion(:,4);
y = motion(:,5);
x = motion(:,6);

% Convert pitch, roll, yaw to mm
% Use arc length formula and radius of sphere = 50 mm
% arc length = theta/360 * 2 * pi * radius (if theta is in degrees)
rad = 50;
p_mm = p_deg./360.*2.*pi.*rad;
r_mm = r_deg./360.*2.*pi.*rad;
y_mm = y_deg./360.*2.*pi.*rad;

% Create shifted versions of each vector
x_shift = [x(1); x(1:end-1)];
y_shift = [y(1); y(1:end-1)];
z_shift = [z(1); z(1:end-1)];
p_mm_shift = [p_mm(1); p_mm(1:end-1)];
r_mm_shift = [r_mm(1); r_mm(1:end-1)];
y_mm_shift = [y_mm(1); y_mm(1:end-1)];

% Take the difference between original and shifted vectors
x_diff = x - x_shift;
y_diff = y - y_shift;
z_diff = z - z_shift;
p_mm_diff = p_mm - p_mm_shift;
r_mm_diff = r_mm - r_mm_shift;
y_mm_diff = y_mm - y_mm_shift;

% Sum the absolute value of the vectors
FD = abs(x_diff) + abs(y_diff) + abs(z_diff) + abs(p_mm_diff) + abs(r_mm_diff) + abs(y_mm_diff);

% Calculate average FD
FDavg = mean(FD);

%% Calculate and save percentage of data points that would be censored (FD > 0.05)
censorNo = sum(FD > 0.5);
censorPer = censorNo/length(FD)*100;

%% Find correlation of X-direction motion with task
rlForce = rForce + lForce;

Motcorr = corrcoef(x,rlForce,'Rows','pairwise');
Xcorr = Motcorr(2);

end