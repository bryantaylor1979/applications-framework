%
%
% workspeet fr calcuating AWB NN curves from bayes curves

% [ qpatha b c ];
outdoors_CT_f = [    4.401867521 -3.709119083 0.949977284];
cloudy_range = [ 0.2 0.35 ];
sunny_range   = [ 0.2725 0.305 ];

indoors_CT_f  = [3.1397 -2.9879 0.8219 ];
indoors_range = [ 0.016 0.42];

cloudy_switch_ev   = 9;
indoors_switch_ev  = 200;

%                 EV r_nrm                      b_nrm
r_nrm_min_pts = [ 0                         (sunny_range(1) + sunny_range(2))/2
                  cloudy_switch_ev     sunny_range(1)
                  indoors_switch_ev    cloudy_range(1)
                  123                     indoors_range(1) ];

r_nrm_max_pts = [ 0                         (sunny_range(1) + sunny_range(2))/2
                  cloudy_switch_ev          cloudy_range(2)
                  indoors_switch_ev         indoors_range(2)
                  123                     indoors_range(2) ];

% make average b_nrm from ct's
r_nrm_min_pts(:,3) = (polyval(outdoors_CT_f,r_nrm_min_pts(:,2)) ...
                 +  polyval(indoors_CT_f,r_nrm_min_pts(:,2)) )/2;

r_nrm_max_pts(:,3) = (polyval(outdoors_CT_f,r_nrm_max_pts(:,2)) ...
                 +  polyval(indoors_CT_f,r_nrm_max_pts(:,2)) )/2;

rb_nrm_min  = [ r_nrm_min_pts(:,2) r_nrm_min_pts(:,3)];
rb_gains_min = nrm_to_gains(rb_nrm_min);

rb_nrm_max   = [ r_nrm_max_pts(:,2) r_nrm_max_pts(:,3)];
rb_gains_max = nrm_to_gains(rb_nrm_max);

r_min_pwl = [  floor(r_nrm_min_pts(:,1)) rb_gains_min(:,1)]             
r_max_pwl = [  floor(r_nrm_max_pts(:,1)) rb_gains_max(:,1)]             
              
%      res_para: 0.005
%      res_perp: 0.PREC = 
x_step = (indoors_range(2) - indoors_range(1)) /13;
x = indoors_range(1):x_step:indoors_range(2);
yo = polyval(outdoors_CT_f,x);
outdoors_ct = [ x' yo' ];

yi = polyval(indoors_CT_f,x);
indoors_ct = [ x' yi' ];

average_ct = [ x'  ((yi + yo)/2)' ];

%figure;
average_rb_ct = sortrows(floor(nrm_to_gains(average_ct)*256+0.5))
plot ( x,yi,'ro' ...
     , x,yo,'go' ...
     , x, average_ct(:,2), 'bo' ...
     ...%, outdoor_rb_ct(:,1), outdoor_rb_ct(:,1),'bx' 
     );

%%
