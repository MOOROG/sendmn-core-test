<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WalletRequest.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.PartnerWalletRequest.WalletRequest" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <base id="Base1" runat="server" target="_self" />
  <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <!-- Flot -->
  <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
  <script src="../../../js/functions.js" type="text/javascript"> </script>

  <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="../../../ui/js/jquery.min.js" type="text/javascript"></script>
  <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
  <script src="../../../ui/js/jquery-ui.min.js" type="text/javascript"></script>
  <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
</head>
<body>
  <form id="form1" runat="server">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <h1></h1>
            <ol class="breadcrumb">
              <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li class="active"><a href="WalletRequest.aspx">Wallet Request</a></li>
            </ol>
          </div>
        </div>
      </div>
      <!-- end .page title-->
      <div class="report-tab">
        <!-- Nav tabs -->
        <div class="listtabs">
          <ul class="nav nav-tabs" role="tablist">
            <li role="presentation" class="active">
              <a href="#list" aria-controls="home" role="tab" data-toggle="tab">Wallet request List</a></li>
            <li><a href="WithdrawMoneyList.aspx">Withdraw Money List</a></li>
          </ul>
        </div>
        <!-- Tab panes -->
        <div class="tab-content">
          <div role="tabpanel" class="tab-pane active" id="list">
            <div class="row">
              <div class="col-md-12">
                <div class="panel panel-default ">
                  <!-- Start .panel -->
                  <div class="panel-heading">
                    <h4 class="panel-title">Wallet request</h4>
                    <div class="panel-actions">
                      <a href="#" class="panel-action panel-action-toggle"></a>
                    </div>
                  </div>
                  <div class="panel-body">
                    <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                    </div>
                  </div>
                </div>
                <!-- End .panel -->
              </div>
              <!--end .col-->
            </div>
            <!--end .row-->
          </div>
          <div role="tabpanel" class="tab-pane" id="Manage">
          </div>
        </div>
      </div>
    </div>

    <script language="javascript" type="text/javascript">
      function State_Click(id, status) {
        $.ajax({
          url: '<%= ResolveUrl("WalletRequest.aspx") %>',
          type: 'POST',
          data: { methodName: "State_Click", id: id, status: status },
          success: function (result) {
            var strng = JSON.stringify(result);
            obj = JSON.parse(strng);
            alert(obj["Msg"])
            if (obj["ErrorCode"] != "1") {
              SubmitForm("<% =GridName%>");
            }
          },
          error: function (result) {
            alert("Sorry! Due to unexpected errors operation terminates !");
          }
        });
      }
    </script>
  </form>
</body>
</html>
