package com.apdplat.module.system.action;

import com.apdplat.module.system.model.BackupScheduleConfig;
import com.apdplat.module.system.service.backup.BackupSchedulerService;
import com.apdplat.module.system.service.backup.BackupService;
import com.apdplat.platform.action.DefaultAction;
import com.apdplat.platform.util.Struts2Utils;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.annotation.Resource;
import org.apache.struts2.convention.annotation.Namespace;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;

@Scope("prototype")
@Controller
@Namespace("/system")
public class BackupAction extends DefaultAction {
    protected final Logger log = LoggerFactory.getLogger(getClass());
    private String date;
    @Resource(name="backupServiceExecuter")
    private BackupService backupService;    
    @Resource(name="backupSchedulerService")
    private BackupSchedulerService backupSchedulerService;
    private int hour;
    private int minute;
    
    
    public String query(){
        Map map=new HashMap();
        BackupScheduleConfig config=backupSchedulerService.getBackupScheduleConfig();
        
        if(config!=null && config.isEnabled()){
            map.put("state", "定时备份数据任务执行频率为每天，时间（24小时制）"+config.getScheduleHour()+":"+config.getScheduleMinute());
            map.put("hour",config.getScheduleHour());
            map.put("minute", config.getScheduleMinute());

        }else{
            map.put("state", "无定时调度任务");
        }
        
        Struts2Utils.renderJson(map);
        return null;
    }
    public String clearTask(){
        String result=backupSchedulerService.unSchedule();
        Struts2Utils.renderText(result);
        return null;
    }
    public String setTask(){     
        if(-1<hour && hour<24 && -1<minute && minute<60){
           String result=backupSchedulerService.schedule(hour, minute);
           Struts2Utils.renderText(result);
        } else{
            Struts2Utils.renderText("调度时间不正确");
        } 
        return null;
    }
    public String store(){
        List<String> existBackup=backupService.getExistBackup();
        List<Map<String,String>> data=new ArrayList<Map<String,String>>();
        for(String item : existBackup){
            Map<String,String> map=new HashMap<String,String>();
            map.put("value", item);
            map.put("text", item);
            data.add(map);
        }
        Struts2Utils.renderJson(data);
        return null;
    }
    public String backup(){
        if(backupService.backup()){
            Struts2Utils.renderText("true");
        }else{
            Struts2Utils.renderText("false");
        }
        return null;
    }
    public String restore(){
        if(date==null || "".equals(date.trim())){
            log.info("请指定恢复数据库到哪一个时间点");
            return null;
        }
        date= date.replace(" ", "-").replace(":", "-");
        if(backupService.restore(date)){
            Struts2Utils.renderText("true");
        }else{
            Struts2Utils.renderText("false");
        }
        return null;
    }
    public void setDate(String date) {
        this.date = date;
    }

    public void setHour(int hour) {
        this.hour = hour;
    }

    public void setMinute(int minute) {
        this.minute = minute;
    }
}
