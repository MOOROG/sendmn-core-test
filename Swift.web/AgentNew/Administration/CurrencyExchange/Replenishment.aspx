<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Replenishment.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.Replenishment" %>

<%@ Register Assembly="AjaxControlToolKit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
  <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="../../../ui/css/style.css" rel="stylesheet" />
  <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
  <script src="../../../js/functions.js" type="text/javascript"> </script>


  <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
  <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>

  <script type="text/javascript">
    function ShowOld(acc) {
      var url = "CashTopUp.aspx?account=" + acc;
      var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
      PopUpWindow(url, param);
    }
    function SwitchShift() {
      if ($("#reciever").val() == "") {
        alert('Хүлээн авагчаа сонгоно уу!')
        return false;
      }
      if (confirm("Are you sure to switch these record?")) {
        $.ajax({
          url: '<%= ResolveUrl("Replenishment.aspx") %>',
          type: 'POST',
          data: { methodName: "Save", receiver: $("#reciever").val() },
          success: function (result) {
            var strng = JSON.stringify(result);
            obj = JSON.parse(strng);
            alert(obj["Msg"])
            location.reload();
          },
          error: function (result) {
            alert("Sorry! Due to unexpected errors operation terminates !");
          }
        });
      }
    }
  </script>
</head>

<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <h1></h1>
            <ol class="breadcrumb">
              <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li class="active"><a href="Replenishment.aspx">REPLENISHMENT </a></li>
            </ol>
          </div>
        </div>
      </div>
      <div class="tab-content">
        <div role="tabpanel" class="tab-pane active" id="list">
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites">
                <div class="panel-heading">
                  <h4 class="panel-title">Account List
                  </h4>
                </div>
                <div class="panel-body">
                  <div class="form-group">
                    <div class="col-md-2">
                      <div class="form-group">
                        <label>Илгээх ажилтан:<span class="errormsg">*</span></label>
                        <asp:DropDownList ID="send" runat="server" Width="100%" CssClass="form-control" AutoPostBack="true">
                        </asp:DropDownList>
                      </div>
                    </div>
                    <div class="col-md-2">
                      <div class="form-group">
                        <label>Хүлээн авах ажилтан:<span class="errormsg">*</span></label>
                        <asp:DropDownList ID="reciever" runat="server" Width="100%" CssClass="form-control">
                        </asp:DropDownList>
                      </div>
                    </div>
                    <div class="col-md-1">
                      <label>&nbsp</label>
                      <input type="button" class="btn btn-primary form-control" onclick="SwitchShift()" value="Switch Shift" />
                    </div>
                  </div>
                  <div id="rpt_replenishment" runat="server" enableviewstate="false"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </form>
</body>
</html>
