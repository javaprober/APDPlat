<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page  import="com.apdplat.module.security.service.OnlineUserService"%>
<%@page  import="com.apdplat.module.security.service.SpringSecurityService"%>
<%@page  import="org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter"%>
<%@page  import="com.apdplat.module.security.service.UserDetailsServiceImpl"%>
<%@page  import="com.apdplat.module.system.service.PropertyHolder"%>
<%@page  import="java.util.Collection"%>
<%@page  import="com.apdplat.platform.util.FileUtils"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<%
response.addHeader("login","true");  
//供记录用户登录日志使用
String userAgent=request.getHeader("User-Agent");
request.getSession().setAttribute("userAgent", userAgent);
if(!SpringSecurityService.isSecurity()){
    //如果没有启用安全机制则直接进入主界面
    response.sendRedirect("platform/index.jsp");
    return;
}
String name=OnlineUserService.getUsername(request.getSession(true).getId());
if(!"匿名用户".equals(name)){
    //用户已经等登录直接进入主界面
    response.sendRedirect("platform/index.jsp");
    return;
}

String message="";
String state=request.getParameter("state");
if(state!=null){
    response.addHeader("state",state);  
}
if("checkCodeError".equals(state)){
    response.addHeader("checkCodeError","true");  
    message="验证码错误";
    response.getWriter().write(message);
    response.getWriter().flush();
    response.getWriter().close();
    return;
}

Object obj=session.getAttribute(UsernamePasswordAuthenticationFilter.SPRING_SECURITY_LAST_USERNAME_KEY);

String lastUsername="";
if(obj!=null){
    lastUsername=obj.toString();
    if(request.getParameter("login_error")!=null){
        String tip=UserDetailsServiceImpl.getMessage(lastUsername);
        if(tip!=null){
            message=tip;
            response.addHeader("login_error","true");  
            response.getWriter().write(message);
            response.getWriter().flush();
            response.getWriter().close();
            return;
        }
    }
 }
String contextPath=com.apdplat.module.system.service.SystemListener.getContextPath();
String appName=PropertyHolder.getProperty("app.name");
String requestCode="";
if(FileUtils.existsFile("/WEB-INF/licence")){
    Collection<String> reqs = FileUtils.getTextFileContent("/WEB-INF/licence");
    if(reqs!=null && reqs.size()==1){
        requestCode=reqs.iterator().next().toString();
    }
}
String shortcut=PropertyHolder.getProperty("module.short.name");
%>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title><%=appName%></title>
    <link rel="shortcut icon" href="images/<%= shortcut %>.ico" />
    <link rel="stylesheet" type="text/css" href="extjs/css/ext-all.css"/>
    <link rel="stylesheet" type="text/css" href="extjs/css/ext-patch.css"/>
    <link rel="stylesheet" type="text/css" href="css/login.css"/>
    <script type="text/javascript" src="extjs/js/adapter/ext/ext-base.js"></script>
    <script type="text/javascript" src="extjs/js/ext-all.js"></script>
    <script type="text/javascript" src="extjs/ux/Toast.js"></script>
    <script type="text/javascript" src="extjs/js/ext-lang-zh_CN.js"></script>
    <script type="text/javascript" src="js/validate.js"></script>
    <script type="text/javascript" src="js/md5.js"></script>
    <script type="text/javascript" src="js/login.js"></script>
    <script type="text/javascript">
        var contextPath='<%=contextPath%>';
        var requestCode='<%=requestCode%>';
        var loginImage='<%=PropertyHolder.getProperty("login.image")%>';
        var logoImage='<%=PropertyHolder.getProperty("logo.image")%>';
        
        //判断当前登录窗口有没有被嵌在其他窗口内部
        function is_toplevel(w){
               return (w.parent == w);
        }
        function autoFit() {
            if(!is_toplevel(this)){
                parent.location.href=this.location.href;
            }

            window.moveTo(0, 0);
            window.resizeTo(window.screen.availWidth,window.screen.availHeight);
        }
        function refreshTheme(){
                  var storeTheme=Ext.util.Cookies.get('theme');
                  if(storeTheme==null || storeTheme==''){
                          storeTheme='ext-all';
                  }
                  Ext.util.CSS.swapStyleSheet("theme", contextPath+"/extjs/css/"+storeTheme+".css");  
        }
        var lastUsername="<%=lastUsername%>";
        var message="<%=message%>";
        Ext.onReady(function()
        {
            autoFit();
            refreshTheme();
            if("<%=state%>"=="checkCodeError"){
                Ext.ux.Toast.msg('登录提示：','验证码错误，请重新登录!');  
            }
            if("<%=state%>"=="session-invalid" || "<%=state%>"=="session-authentication-error"){
                Ext.ux.Toast.msg('操作提示：','操作已经超时，请重新登录!');  
            }
            if("<%=state%>"=="session-expired"){
                Ext.ux.Toast.msg('操作提示：','您已被踢下线，请重新登录!');  
            }
            if(message!=""){
                Ext.ux.Toast.msg('登录提示：',message); 
            }
            var win=new LoginWindow();
            win.show();
            if(lastUsername!=""){
                parent.Ext.getCmp('j_username').setValue(lastUsername);
            }
            Ext.get('loading-mask').fadeOut( {
                    remove : true
            });
            fixPng();
            if(""!=requestCode){
                //购买产品
                BuyModel.show(requestCode);
            }
        })
    </script>
    <script type="text/javascript" src="js/MSIE.PNG.js"></script>

</head>
<body>

<div id="loading-mask">
	<div id="loading">
            <div style="text-align:center;padding-top:26%"><img alt="Loading..."  src="images/extanim32.gif" width="32" height="32" style="margin-right:8px;"/>Loading...</div>
	</div>
</div>

</body>
</html>