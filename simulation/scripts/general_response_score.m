function score = general_response_score(r,out,plan,interval)
%GENERAL_RESPONSE_SCORE Fixed native-time score, with no clock/state fitting.
st=out.flight_visualization;g=r.GPS;ct=r.CTUN;at=r.ATT;v=r.EKFVelocity;
a=interval(1)-r.SourceInterval_s(1);b=interval(2)-r.SourceInterval_s(1);
g=g(g.Time_s>=a & g.Time_s<=b,:);ct=ct(ct.Time_s>=a & ct.Time_s<=b,:);
at=at(at.Time_s>=a & at.Time_s<=b,:);v=v(v.Time_s>=a & v.Time_s<=b,:);
assert(min([height(g),height(ct),height(at),height(v)])>=5);
dxy=interp1(st.Time,st.Data(:,1:2),g.Time_s)-g{:,{'North_m','East_m'}};
dz=interp1(st.Time,st.Data(:,3),ct.Time_s)-ct.Alt;
dvz=interp1(out.rtl_vertical_velocity.Time,out.rtl_vertical_velocity.Data,ct.Time_s)-ct.CRt;
dv=[interp1(out.diagnostic_vn.Time,out.diagnostic_vn.Data,v.Time_s)-v.VN,...
    interp1(out.diagnostic_ve.Time,out.diagnostic_ve.Data,v.Time_s)-v.VE];
pred=ardupilot_to_model_attitude(interp1(st.Time,unwrap(st.Data(:,4:6),[],1),at.Time_s));
datt=pred-deg2rad(at{:,{'Roll','Pitch','Yaw'}});
datt=rad2deg(atan2(sin(datt),cos(datt)));
errors=[sqrt(mean(sum(dxy.^2,2))),sqrt(mean(dz.^2)),sqrt(mean(sum(dv.^2,2))),...
    sqrt(mean(dvz.^2)),sqrt(mean(datt.^2,1)),max(abs(dz))];
assert(all(isfinite(errors)));
components=max(0,10-2*errors./plan.ToleranceFor8);
score=struct('Interval_s',interval,'Value',min(components),'Passed',all(components>=8),...
    'Components',table(string(plan.Components(:)),errors(:),plan.ToleranceFor8(:),components(:),...
    'VariableNames',{'Component','Error','ToleranceFor8','Score'}),...
    'SampleCounts',[height(g),height(ct),height(v),height(ct),height(at),height(at),height(at),height(ct)]);
end
