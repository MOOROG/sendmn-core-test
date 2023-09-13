<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.Notification.ApplicationLogs.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
</head>
<body>
    <%--  <% var sl = new SwiftLibrary();%>
    <% sl.BeginHeaderForGrid("Application Logs » View"); %>--%>
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <ol class="breadcrumb">
                        <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModule('system_security')">System Security</a></li>
                        <li class="active"><a href="manage.aspx">Transaction View Logs</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default ">
                    <div class="panel-heading">
                        <h4 class="panel-title">Log Details</h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-12">
                                <asp:Label ID="Label1" runat="server" CssClass="Label"></asp:Label>
                                <div class="form-group form-inline">
                                    <label class="col-md-2 control-label">Date :</label>
                                    <div class="col-md-3">
                                        <asp:Label ID="createdDate" runat="server" CssClass="control-label"></asp:Label>
                                    </div>
                                    <label class="col-md-2 control-label">Table :</label>
                                    <div class="col-md-3">
                                        <asp:Label ID="tableName" runat="server" CssClass="control-label"></asp:Label>
                                    </div>
                                </div>
                                <div class="form-group form-inline">
                                    <label class="col-md-2 control-label">Data Id:</label>
                                    <div class="col-md-3">
                                        <asp:Label ID="dataId" runat="server" CssClass="control-label"></asp:Label>
                                    </div>
                                    <label class="col-md-2 control-label">User :</label>
                                    <div class="col-md-3">
                                        <asp:Label ID="createdBy" runat="server" CssClass="control-label"></asp:Label>
                                    </div>
                                </div>
                                <div class="form-group form-inline">
                                    <label class="col-md-2 control-label">Log Type:</label>
                                    <div class="col-md-3">
                                        <asp:Label ID="logType" runat="server" CssClass="control-label"></asp:Label>
                                    </div>
                                    <div class="col-md-3">
                                        <div id="changeDetails" class="formLabel" align="left" runat="server">Changes Details :</div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <div class="table-responsive">
                                        <div id="rpt_grid" runat="server"></div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <input id="Button1" type="button" value="&lt;&lt; Back" class="btn btn-primary m-t-25" onclick=" javascript: history.back(1); return false; " />
                                    </div>
                                    <label class="col-md-3 control-label"></label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%--<div  style="padding-top: 50px; width: 70%; height: 80%;">
        <% sl.BeginForm("Log Details");%>
    
        <table border="0"  cellspacing="5" cellpadding="5" class="container" width="100%"  >  

            <tr> 
        
                <td nowrap="nowrap" colspan="8">
                    <asp:Label ID="lblmsg" runat="server" CssClass="Label"></asp:Label><br />
     
                </td>
            </tr>

            <tr>
                <td  nowrap= "nowrap" ><div align="left" class="formLabel">  Date :--%>
    <%--                    <asp:Label ID = "createdDate" runat="server" CssClass = "formLabel"></asp:Label></div> </td>
                <td></td>
    
                <td  nowrap= "nowrap" colspan="4" ><div align="left" class="formLabel">  
                                                       Table : <asp:Label ID = "tableName" runat="server" CssClass = "formLabel" ></asp:Label> </div></td>
         
      
    
       
            </tr>
            <tr>
                <td  nowrap= "nowrap" ><div align="left" class="formLabel">  Data Id : 
                                           <asp:Label ID = "dataId" runat="server" CssClass = "formLabel"></asp:Label></div></td>
                <td></td>
       
                <td  nowrap= "nowrap" colspan="2" ><div align="left" class="formLabel">  User : 
                                                       <asp:Label ID = "createdBy" runat="server" CssClass = "formLabel"></asp:Label></div></td>
            </tr>
            <tr>
                <td  nowrap= "nowrap" >
                    <div align="left" class="formLabel">  Log Type : 
                        <asp:Label ID = "logType" runat="server" CssClass = "formLabel"></asp:Label>
                    </div>
                </td>
            </tr>
            <tr>--%>
    <%--  <td colspan="4"> <div id = "changeDetails" class="formLabel" align="left" runat ="server">Changes Details :</div> 
                    <div id="rpt_grid" runat="server"></div>
                </td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td colspan="7">
                    <br />
                    <input id="Button1" type="button" value="&lt;&lt; Back" class="button" onClick=" javascript:history.back(1);return false; " />

                </td>
    
            </tr>
        </table>


        <% sl.EndForm();%>
    </div>
      
    <% sl.EndHeaderForGrid();%>

    <!--################  end style -->--%>
</body>
</html>
