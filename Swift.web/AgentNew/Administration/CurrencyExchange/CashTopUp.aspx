<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CashTopUp.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.CashTopUp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title></title>
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/js/swift_calendar.js" type="text/javascript"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

  <script type="text/javascript">
    $(document).ready(function () {
      function unformatNumber(n) {
        if (n == undefined || n == '')
          return 0;
        return parseFloat(n.toString().replace(/[^0-9\.-]+/g, ""));
      }

      $(".curId").text($("#curVal").val());
      $(".closeAmount").keyup(function (e) {
        let val = e.target.value;
        val = val.replace(/[^0-9]/g, '');
        e.target.value = val;
        let i = $(this).closest('tr').index();
        $(".closeBalanceAmt" + i).text($(".note" + i).text() * this.value);
        $(".diff" + i).text(this.value - $(".curBalance" + i).text());
        $(".diffAmount" + i).text(($(".note" + i).text() * this.value) - $(".curBalanceAmt" + i).text());
        console.log(($(".note" + i).text() * this.value) - $(".curBalanceAmt" + i).text())
      })
      $(".topUpAmount").keyup(function (e) {
        let val = e.target.value;
        val = val.replace(/[^0-9]/g, '');
        e.target.value = val;
      })
      $(".removeAmount").keyup(function (e) {
        let val = e.target.value;
        val = val.replace(/[^0-9]/g, '');
        e.target.value = val;
        let i = $(this).closest('tr').index();
        console.log($(this).val() + "//" + $(".curBalance" + i).text())
        if (e.target.value > unformatNumber($(".curBalance" + i).text())) {
          e.target.value = $(".curBalance" + i).text();
        }
      })
    })

    function UpdateRate() {
      if (confirm("Are you sure to update this record?")) {
        let topUpVal = "";
        let removeVal = "";
        let closeVal = "";
        $('.updateBody tr').each(function (i, value) {
          i = i + 1;
          if ($(".account" + i).text() != '' && $(".topUp" + i).val() > 0) {
            if (topUpVal != "") {
              topUpVal = topUpVal + "," + $(".note" + i).text() + ":" + $(".topUp" + i).val();
            }
            else {
              topUpVal = $(".note" + i).text() + ":" + $(".topUp" + i).val();
            }
          }
          if ($(".account" + i).text() != '' && $(".closeBalance" + i).val() > 0) {
            if (closeVal != "") {
              closeVal = closeVal + "," + $(".note" + i).text() + ":" + $(".closeBalance" + i).val();
            }
            else {
              closeVal = $(".note" + i).text() + ":" + $(".closeBalance" + i).val();
            }
          }
          if ($(".account" + i).text() != '' && $(".remove" + i).val() > 0) {
            if (removeVal != "") {
              removeVal = removeVal + "," + $(".note" + i).text() + ":" + $(".remove" + i).val();
            }
            else {
              removeVal = $(".note" + i).text() + ":" + $(".remove" + i).val();
            }
          }
        })
        var data = {
          account: $("#accVal").val(),
          currency: $("#curVal").val(),
          topup: topUpVal,
          remove: removeVal,
          closeBalance: closeVal,
        }
        console.log(data)
        $.ajax({
          url: '<%= ResolveUrl("CashTopUp.aspx") %>',
            type: 'POST',
            data: { methodName: "Save", data: JSON.stringify(data) },
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
  <style>
    table, th, td {
      border: solid 1px #000;
      padding-left: 20px;
      padding-right: 20px;
      color: black;
      text-align: center;
    }
  </style>
</head>
<body>
  <form id="form2" runat="server">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-md-12">
          <div class="panel-body">
            <asp:TextBox ID="curVal" runat="server" CssClass="form-control hidden"></asp:TextBox>
            <asp:TextBox ID="accVal" runat="server" CssClass="form-control hidden"></asp:TextBox>
            <div id="function_grid" runat="server"></div>
          </div>
          <div class="col-md-2" style="float:right">
            <input type="button" class="btn btn-primary form-control" onclick="UpdateRate()" value="Save" />
          </div>
        </div>
      </div>
    </div>
  </form>
</body>
</html>
