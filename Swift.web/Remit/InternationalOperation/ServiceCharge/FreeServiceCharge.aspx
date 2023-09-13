<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FreeServiceCharge.aspx.cs" Inherits="Swift.web.Remit.InternationalOperation.ServiceCharge.FreeServiceCharge" %>

<!DOCTYPE html>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
  <title></title>
  <script src="/js/swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"> </script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
  <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
  <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/ui/js/bootstrap-datepicker.js" type="text/javascript"></script>
  <script src="/ui/js/pickers-init.js" type="text/javascript"></script>
  <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>

  <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
  <style type="text/css">
    .label {
      color: #979797 !important;
      font-size: 12px;
    }

    .disabled {
      background: #EFEFEF !important;
      color: #666666 !important;
    }

    legend {
      background-color: red !important;
      color: white !important;
      margin-bottom: 0 !important;
      font-family: Verdana, Arial;
      font-size: 18px;
      margin-right: 2px;
      padding-bottom: 6px !important;
      text-align: -webkit-center;
    }

    fieldset {
      padding: 5px !important;
      margin: 20px !important;
      border: 2px solid #943337 !important
    }
  </style>
  <script type="text/javascript">
    function CheckFormValidation() {
      var reqField = "sendCountry,fromDate,toDate,isFirst";
      if (ValidRequiredField(reqField) == false) {
        return false;
      }
      GetElement("addNewAccount").click();
      return true;
    }
    

  </script>
</head>
<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <h1></h1>
                        <ol class="breadcrumb">
              &nbsp<li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
               <li><a href="#" onclick="return LoadModule('adminstration')">International Operation </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Service Charge/Commission</a></li>
                            <li class="active"><a href="List.aspx">Free ServiceCharge</a></li>
            </ol>
          </div>
        </div>
        <div class="col-md-12">
          <div class="form-group">            
              <div class="col-md-2">
              <label class="control-label">
                <b>Country:</b>
              </label>
              <asp:DropDownList ID="sendCountry" runat="server" CssClass="form-control"  AutoPostBack="True"></asp:DropDownList>
            </div>
            <div class="col-md-2">
              <label class="control-label">
                <b>From Date:</b> 
              </label>
              <div class="input-group m-b">
                <span class="input-group-addon">
                  <i class="fa fa-calendar" aria-hidden="true"></i>
                </span>
                <asp:TextBox ID="fromDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
              </div>
            </div>
             <div class="col-md-2">
              <label class="control-label">
                <b>To Date:</b> 
              </label>
              <div class="input-group m-b">
                <span class="input-group-addon">
                  <i class="fa fa-calendar" aria-hidden="true"></i>
                </span>
                <asp:TextBox ID="toDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
              </div>
            </div>
              <%--<div class="col-md-2">
              <label class="control-label">
                <b>Is First:</b>
              </label>
                 <asp:DropDownList ID="isFirst" runat="server" Width="100%" CssClass="form-control">
                                                    <asp:ListItem Value="N" Text="No"></asp:ListItem>
                                                    <asp:ListItem Value="Y" Text="Yes"></asp:ListItem>
                                                </asp:DropDownList>
              <asp:DropDownList ID="isFirst" runat="server" CssClass="form-control"  AutoPostBack="True"></asp:DropDownList>
            </div>--%>
            <div class="col-md-2">
              <label class="control-label">
                <b>Amount (₮):</b>
              </label>
              <asp:TextBox ID="amountId" disabled="disabled" runat="server" CssClass="form-control" value="0"></asp:TextBox>
            </div>

            <div class="col-md-1">
              <label class="control-label" style="width: 150px; color: white">
                Save
              </label>
               <input type="button" value="Save" id="addNew" runat="server" class="btn btn-primary m-t-25" 
              onclick="CheckFormValidation();" />
            <asp:Button ID="addNewAccount" runat="server" Text="Add" OnClick="add_Click" Style="display: none" />
            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
              ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="addNewAccount">
            </cc1:ConfirmButtonExtender>
              </div>

           
           
          </div>

          <div class="form-group">          
             <div class="row">
        <div class="col-md-12">
          <div class="panel panel-default ">
            <div class="panel-heading">
              <h4 class="panel-title">sample</h4>
              <div class="panel-actions">
                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
              </div>
            </div>
            <div class="panel-body">
              <div id="rpt_grid" runat="server"></div>
            </div>
          </div>
        </div>
      </div>
            
           
          </div>
          <br />
          <%--<div class="form-group">
            <div class="col-md-6">
               <input type="button" value="Save" id="addNew" runat="server" class="btn btn-primary m-t-25" style="float: right;"
              onclick="CheckFormValidation();" />
            <asp:Button ID="addNewAccount" runat="server" Text="Add" OnClick="add_Click" Style="display: none" />
            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
              ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="addNewAccount">
            </cc1:ConfirmButtonExtender>
              </div>
           
          </div>--%>
        </div>
      </div>
  </form>
</body>
</html>
