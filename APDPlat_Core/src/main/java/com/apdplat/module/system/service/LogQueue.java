package com.apdplat.module.system.service;

import com.apdplat.platform.model.Model;
import com.apdplat.platform.service.ServiceFacade;
import java.util.concurrent.ConcurrentLinkedQueue;
import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 *
 * @author ysc
 */
@Service
public class LogQueue {
    protected final Logger log = LoggerFactory.getLogger(getClass());
    @Resource(name = "serviceFacade")
    private ServiceFacade serviceFacade;
    private static ConcurrentLinkedQueue <Model> logs =  new  ConcurrentLinkedQueue <Model>();
    private static int logQueueMax=Integer.parseInt(PropertyHolder.getProperty("logQueueMax"));
    public static synchronized void addLog(Model log){
        logs.add(log);
        if(logs.size()>logQueueMax){
            queue.saveLog();
        }
    }
    private static LogQueue queue=null;
    public static LogQueue getLogQueue(){
        return queue;
    }
    @PostConstruct
    public void execute(){
        queue=this;
    }
    public synchronized void saveLog(){
        int len=logs.size();
        int success=0;
        log.info("保存前队列中的日志数目为："+len);
        try{
            for(int i=0;i<len;i++){
                Model model = logs.remove();
                try{
                    serviceFacade.create(model);
                    success++;
                }catch(Exception ex){
                    ex.printStackTrace();
                    log.error("保存日志失败:"+model.getMetaData());
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            log.error("保存日志抛出异常");
        }
        log.info("成功保存 "+success+" 条日志");
        log.info("保存后队列中的日志数目为："+logs.size());
    }
}
