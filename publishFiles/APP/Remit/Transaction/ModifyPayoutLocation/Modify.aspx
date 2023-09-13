<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Modify.aspx.cs" Inherits="Swift.web.Remit.Transaction.ModifyPayoutLocation.Modify" %>
<%@ Import Namespace="Swift.web.Library" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target = "_self" runat = "server" />
     <base id="Base2" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js" type="text/javascript"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
     <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
     <script type="text/javascript">
         function CallBack(mes) {
             var resultList = ParseMessageToArray(mes);
             alert(resultList[1]);

             if (resultList[0] != 0) {
                 return;
             }

             window.returnValue = resultList[2];
             window.close();
         }
         function PickAgent() {
             var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
             var url = urlRoot + "/Remit/Administration/AgentSetup/PickBranch.aspx";
             var param = "dialogHeight:400px;dialogWidth:940px;dialogLeft:200;dialogTop:100;center:yes";
             var res = PopUpWindow(url, param);
             if (res == "undefined" || res == null || res == "") {

             }
             else {
                 var result = res.split('|');
                 SetValueById("<%=hdnBranchName.ClientID %>", result[0], "");
                 SetValueById("<%=hdnBranchId.ClientID %>", result[1], "");
                 SetValueById("sendBy", result[0] + "|" + result[1], "");
              
             }
         }
     </script>
             
</head>
<body>
    <form id="form1" runat="server">
       <asp:ScriptManager runat="server" id="sc"></asp:ScriptManager>
    <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance </a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="ManageSearch.aspx">Modify Payout Location</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <!--end .row-->
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">Find By Control No</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="form-group">
                                    <asp:Label ID="lblMsg" runat="server"></asp:Label>
                                </div>
                                <div class="form-group">
                                    <label>
                                        Field Name : 
                                    </label>
                                    <asp:Label ID="lblFieldName" runat="server"></asp:Label>
                                </div>
                                <div class="form-group">
                                    <label>
                                        Old Value :
                                    </label>
                                    <asp:Label ID="lblOldValue" runat="server"></asp:Label>
                                </div>
                                <div class="form-group" id="rptShowOther" runat="server">
                                    <label>
                                        New Value : 
                                    </label>
                                    <asp:DropDownList ID="ddlNewValue" runat="server" class="form-control"></asp:DropDownList>
                                </div>
                                <div id="showBranch" runat="server" visible="false">
                                <div class="form-group">
                                    <label>
                                        Bank :
                                    </label>
                                    <asp:DropDownList ID="ddlBank" runat="server" class="form-control"
                                    AutoPostBack="True" onselectedindexchanged="ddlBank_SelectedIndexChanged"></asp:DropDownList>
                                </div>
                                <div class="form-group">
                                    <label>
                                        Branch : 
                                    </label>
                                    <asp:DropDownList ID="ddlBranch" runat="server" class="form-control"></asp:DropDownList>
                                </div>
                                </div>
                                <div class="form-group" id="rptAccountNo" runat="server" visible="false">
                                    <label>
                                        New Value :
                                    </label>
                                    <asp:TextBox ID="txtNewValue" runat="server" class="form-control"></asp:TextBox>
                                </div>
                                <div class="form-group" id="rptBranch" runat="server" visible="false">
                                    <label>
                                        New Value :
                                    </label>
                                    <input type="text" readonly="readonly" id="sendBy" class="form-control"/>
                                    <input type="button" value="Pick" onclick="PickAgent();" class="btn btn-primary"/>
                                    <asp:HiddenField ID="hdnBranchName" runat="server"/>
                                    <asp:HiddenField ID="hdnBranchId" runat="server" />  
                                </div>
                                <div class="form-group">
                                    <asp:Button ID="btnUpdate" runat="server" Text=" Update " CssClass="btn btn-primary" 
                                        onclick="btnUpdate_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <asp:HiddenField ID = "hddField" runat = "server" />
            <asp:HiddenField ID = "hddOldValue" runat = "server" />
            <asp:HiddenField ID = "hdnValueType" runat="server" />
        </div>
    </form>
</body>
</html>