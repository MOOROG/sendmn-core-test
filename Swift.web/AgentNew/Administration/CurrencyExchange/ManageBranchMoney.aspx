<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageBranchMoney.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.ManageBranchMoney" %>

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
    function submit_form() {
      var btn = document.getElementById("<%=btnHidden.ClientID %>");
      if (btn != null)
        btn.click();
    }

    function nav(page) {
      var hdd = document.getElementById("money_page");
      if (hdd != null)
        hdd.value = page;

      submit_form();
    }

    function amountKeyup(d, id, i) {
      let val = d.target.value;
      if (val != "") {
        $("#" + id + i).attr("disabled", true);
        val = val.replace(/,/g, '');
        val = val.replace(/[A-z^]/g, '');
        val = val.replace(/ /g, '');
        d.target.value = val;
      } else {
        $("#" + id + i).attr("disabled", false);
      }
      if (id == 'addAmount')
        $("#trAmountId" + i).val(d.target.value * (-1));
      else
        $("#trAmountId" + i).val(d.target.value);
    }
    function unformatNumber(n) {
      if (n == undefined || n == '')
        return 0;
      return parseFloat(n.toString().replace(/[^0-9\.-]+/g, ""));
    }
    function UpdateRate() {
      if (confirm("Are you sure to update this record?")) {
        let i = 0;
        let error = 0;
        var rowInfo = [];
        $('#repBody tr').each(function () {
          i = i + 1;
          if (GetValue("trAmountId" + i) != '') {
            rowInfo.push({
              id: GetValue("trId" + i),
              currency: GetValue("trcurId" + i),
              amount: GetValue("trAmountId" + i),
              reportCode: GetValue("traccReportId" + i),
              receiverUser: $("#reciever").val(),
            })
          }
        })
        let str = JSON.stringify(rowInfo);
        str = JSON.parse("[" + str + "]");
        if (error == 0 && rowInfo.length > 0) {
        $.ajax({
            url: '<%= ResolveUrl("ManageBranchMoney.aspx") %>',
            type: 'POST',
            data: { methodName: "Save", data: JSON.stringify(rowInfo) },
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
              <li class="active"><a href="List.aspx">Manage Branch Money</a></li>
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
                  <h4 class="panel-title">Manage Branch Money
                  </h4>
                </div>
                <div class="panel-body">
                  <div class="form-group">
                    <div class="col-md-2">
                      <label class="control-label">
                        <b>/Хаан банк-7000011/</b>
                      </label>
                      <asp:TextBox ID="amount" disabled="disabled" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="col-md-3">
                      <div class="form-group">
                        <label>
                          Хүлээн авах ажилтан:<span class="errormsg">*</span></label>
                        <asp:DropDownList ID="reciever" runat="server" Width="100%" AutoPostBack="true" CssClass="form-control">
                        </asp:DropDownList>
                      </div>
                    </div>
                  </div>
                  <div id="rpt_replenishment" runat="server" enableviewstate="false"></div>
                  <div class="col-md-12">
                    <input type="button" class="btn btn-primary form-control" onclick="UpdateRate()" value="Save" />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />
  </form>
</body>
</html>
