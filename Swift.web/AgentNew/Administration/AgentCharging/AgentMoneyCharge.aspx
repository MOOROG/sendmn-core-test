<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AgentMoneyCharge.aspx.cs" Inherits="Swift.web.AgentNew.Administration.AgentCharging.AgentMoneyCharge" %>

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
      var reqField = "sendAgent,dateId,amountCurrencyId,rateId,accListId,";
      if (ValidRequiredField(reqField) == false) {
        return false;
      }
      GetElement("addNewAccount").click();
      return true;
    }
    function amountKeyup(d) {
      let val = d.target.value;
      if (val != "") {
        val = val.replace(/,/g, '');
        val = val.replace(/[^0-9]/g, '');
        val = String(val).replace(/(.)(?=(\d{3})+$)/g, '$1,');
        d.target.value = val;
      }
    }   
    function amountBlur() {
      var val = $('#<%=rateId.ClientID%>').val();
      var val1 = $('#<%=amountCurrencyId.ClientID%>').val();
      var amnt = val.replace(/,/g, "");
      var amntRate = val1.replace(/,/g, "");
      amnt = amnt * amntRate;
      if (amnt > 0) {
        amnt = String(amnt).replace(/(.)(?=(\d{3})+$)/g, '$1,');
      }
      $('#<%=amountId.ClientID%>').val(amnt);
    }

  </script>
</head>
<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <ol class="breadcrumb">
              &nbsp<li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <%--<li class="active"><a href="List.aspx">Load Money </a></li>--%>
            </ol>
          </div>
        </div>
        <div class="col-md-12">
          <div class="form-group">
            <div class="col-md-3">
              <label class="control-label">
                <b>Agent:</b>
              </label>
              <asp:DropDownList ID="sendAgent" runat="server" CssClass="form-control" OnSelectedIndexChanged="Acc_SelectedIndexChanged" AutoPostBack="True"></asp:DropDownList>
            </div>
            <div class="col-md-3">
              <label class="control-label">
                <b>Account:</b>
              </label>
              <asp:DropDownList ID="accListId" runat="server" CssClass="form-control">
              </asp:DropDownList>
            </div>

            <div class="col-md-3">
              <label class="control-label">
                <b>Date:</b> 
              </label>
              <div class="input-group m-b">
                <span class="input-group-addon">
                  <i class="fa fa-calendar" aria-hidden="true"></i>
                </span>
                <asp:TextBox ID="dateId" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
              </div>
            </div>
          </div>
          <div class="form-group">
            <div class="col-md-3">
              <label class="control-label">
                <b>Amount ($):</b>
              </label>
              <asp:TextBox ID="amountCurrencyId" runat="server" Placeholder="Enter Amount ($) To be Upload" CssClass="form-control" onkeyup="amountKeyup(event);" onblur="javascript:amountBlur();"></asp:TextBox>
            </div>
            <div class="col-md-3">
              <label class="control-label">
                <b>Rate:</b>
              </label>
              <asp:TextBox ID="rateId" runat="server" Placeholder="Enter Rate To be Upload" CssClass="form-control" onkeyup="amountKeyup(event);" onblur="javascript:amountBlur();"></asp:TextBox>
            </div>
            <div class="col-md-3">
              <label class="control-label">
                <b>Amount (₮):</b>
              </label>
              <asp:TextBox ID="amountId" disabled="disabled" runat="server" CssClass="form-control"></asp:TextBox>
            </div>
          </div>
          <br />
          <div class="form-group">
            <input type="button" value="Add" id="addNew" runat="server" class="btn btn-primary m-t-25"
              onclick="CheckFormValidation();" />
            <asp:Button ID="addNewAccount" runat="server" Text="Add" OnClick="add_Click" Style="display: none" />
            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
              ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="addNewAccount">
            </cc1:ConfirmButtonExtender>
          </div>
        </div>
      </div>
  </form>
</body>
</html>
