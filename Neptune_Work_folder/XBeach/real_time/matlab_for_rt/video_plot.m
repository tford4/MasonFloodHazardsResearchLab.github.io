
clear;
close all;

run(['/home/vse/Neptune_Work_folder/XBeach/real_time/matlab_for_rt/','oetsettings.m']);
xbo=xb_read_output('/home/vse/Neptune_Work_folder/XBeach/real_time/output/');
xbo2=xbo.data(1).value;

date1=datetime('now');
delta_t=datenum(date1);
delta_t=delta_t-hours(2);
delta_t2(1:216)=delta_t+minutes(1:20:4320);

%%
 for ii=1
     H          =squeeze(xbo.data(2).value(ii,:));
     zs         =squeeze(xbo.data(22).value(ii,:));
     zb         =squeeze(xbo.data(17).value(ii,:));
     u          =squeeze(xbo.data(7).value(ii,:));
     v          =squeeze(xbo.data(12).value(ii,:));
     x          =squeeze(xbo2.data(18).value);
     y          =squeeze(xbo2.data(19).value);
     t          =squeeze(xbo2.data(20).value);
 end

for i=1
    for ii=1:787
        if zb(i,ii)>.05
            veg_h(i,ii)=.15;
        end
        if zb(i,ii)>0 && zb(i,ii)<.25
            veg_h(i,ii)=.5;
        end
        if zb(i,ii)<=0
            veg_h(i,ii)=0;
        end
        if zb(i,ii)>1.25
            veg_h(i,ii)=.1;
        end
    end
end
%%
vid_path=('/home/vse/Neptune_Work_folder/XBeach/real_time/figures/');
cd(vid_path);
video=VideoWriter('xbeach_mgb');

video.FrameRate=4;
open(video);
t_end=length(t);

for i=1:t_end
         if i<t_end
            H1          =squeeze(xbo.data(2).value(i,:));
            zs1         =squeeze(xbo.data(22).value(i,:));
            zb1         =squeeze(xbo.data(17).value(i,:));
            u1         =squeeze(xbo.data(7).value(i,:));
            v1          =squeeze(xbo.data(12).value(i,:));
            x1          =squeeze(xbo2.data(18).value);
            y1          =squeeze(xbo2.data(19).value);
        
        A=figure('units','normalized','outerposition',[0 0 1 1]);
        A(1)=plot(x1,H1+zs1,'c'); hold on
        A(2)=plot(x1,zs1,'b'); hold on
        A(3)=plot(x1,sqrt(u1.^2+v1.^2),'r');hold on
        A(4)=plot(x1,zb1,'k'); hold on
        for j = 1:length(x1)
            A(5)=plot([x1(j),x1(j)],[zb1(j) zb1(j)+veg_h(j)],'Color',[76 153 0]/255);
        end
	set(A(1),'LineWidth',1.75);
        set(A(2),'LineWidth',1.75);
        set(A(3),'LineWidth',1.75);
        set(A(4),'LineWidth',1.75);
        set(A(5),'LineWidth',.5);
        legend('waves','tide','total velocity','bathymetry','vegetation','Location','NorthWest');
        axis([1400 2150 -1.75 1.75]);
        xlabel('length (m)','FontSize',12);
        ylabel('elevation (m)','FontSize',12);
	str=strcat({'Magothy Bay Natural Area Preserve '},{datestr(delta_t2(i),' mm-dd-yyyy HH:MM')});
        title(str,'FontSize',16,'Fontweight','bold');
	saveas(gcf,sprintf('xbeach_mgb%d.png',i));
        F(i)=getframe(i);
        writeVideo(video,F(i));
         else
             break;
         end
end    
close(video);
