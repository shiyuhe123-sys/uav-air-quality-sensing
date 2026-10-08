%% Reproduce the frozen public RTL trajectory and its native-rate score.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'scripts'),fullfile(root,'model'));
result=run_rtl_portfolio_demo('verify');
assert(~result.Score.Passed,'The original 8/10 goal must remain recorded as unmet.');
assert(result.Score.SampleCounts(1)==46 && result.Score.SampleCounts(2)==92);
fprintf('PASS: public RTL trajectory, all eight metrics, duration and sample counts.\n');
