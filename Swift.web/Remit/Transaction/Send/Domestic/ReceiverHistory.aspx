<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReceiverHistory.aspx.cs" Inherits="Swift.web.Remit.Transaction.Send.Domestic.ReceiverHistory" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../ui/js/jquery.min.js"></script>
    <script src="../../../../../js/Swift_grid.js"></script>
    <script src="../../../../js/functions.js"></script>
    
  <%--  <link href="../../../../../css/swift_component.css" rel="stylesheet" />
    --%>
    <script language="javascript" type="text/javascript">
        function CallBack(mes) {
            if (mes == "") {
                return;
            }
            window.returnValue = mes;
            window.close();
        }
</script>
</head>
<body>
<form id="form1" runat="server">
     <div class="container">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>RECEIVER HISTORY 
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Send Money</a></li>
                            <li class="active"><a href="#">Receiver History List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
   
                   
    
        <div class="row">
                <div id = "rpt_grid" runat = "server" class="gridDiv"></div> 
            <div class="col-sm-2"><asp:Button ID="btnSelect" runat="server" CssClass="btn btn-primary" Text="Select" 
                    onclick="btnSelect_Click"/> 
            </div>
        </div>
         </div>
</form>
</body>
</html>


