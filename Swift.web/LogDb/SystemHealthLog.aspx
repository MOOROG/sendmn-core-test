<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemHealthLog.aspx.cs" Inherits="Swift.web.LogDb.SystemHealthLog" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <title></title>
  <base id="Base1" runat="server" target="_self" />
  <link href="../ui/css/style.css" rel="stylesheet" />
  <link href="../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <script src="../js/swift_grid.js" type="text/javascript"> </script>
  <script src="../js/functions.js" type="text/javascript"> </script>

  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
  <script src="/js/swift_calendar.js"></script>
  <script src="/ui/js/jquery-ui.min.js"></script>
  <script type="text/javascript">
    var half = [];
    var full = [];
    var halfs = [];
    var fulls = [];
    var arrInt = [3, 6];
    $(document).ready(function () {
      arrInt.forEach(function (indexs) {
        More(event, indexs);
      })
      ShowCalFromToUpToToday("#sendAPILog_fromDate", "#sendAPILog_toDate", 1);
    });
    function More(event, indexs) {
      var messages = document.querySelectorAll(`tr > td:nth-child(${indexs})`);
      messages.forEach(function (item, index) {
        if (indexs == 3) {
          half.push(item.innerText.substring(0, 50));
          full.push(item.innerText);
        } else {
          halfs.push(item.innerText.substring(0, 50));
          fulls.push(item.innerText);
        }
        if (index != -1) {
          item.innerText = item.innerText.substring(0, 50);
          item.innerHTML = item.innerHTML + ` <a onclick='ShowFull(${index}, ${indexs})'>...Show more</a>`;
        }
      });
      event.preventDefault()
      return false;

    }
    function ShowLess(index, indexs) {
      var messages = document.querySelectorAll(`tr > td:nth-child(${indexs})`);
      if (indexs == 3) {
        messages[index].innerText = half[index];
      } else {
        messages[index].innerText = halfs[index];
      }
      messages[index].innerHTML = messages[index].innerHTML + ` <a onclick='ShowFull(${index}, ${indexs})'>...Show more</a>`;
      event.preventDefault()
      return false;
    }

    function ShowFull(index, indexs) {
      var messages = document.querySelectorAll(`tr > td:nth-child(${indexs})`);
      if (indexs == 3) {
        messages[index].innerText = full[index];
      } else {
        messages[index].innerText = fulls[index];
      }
      messages[index].innerHTML = messages[index].innerHTML + `<a onclick='ShowLess(${index}, ${indexs})'> Show less</a>`;
      event.preventDefault()
      return false;
    }
  </script>
</head>
<body>
  <form id="form1" runat="server">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <ol class="breadcrumb">
              <li><a href="../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li class="active"><a href="VoucherLog.aspx">System Health Log</a></li>
            </ol>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-md-12">
          <div class="panel panel-default recent-activites">
            <div class="panel-heading">
              <h4 class="panel-title">System Health Log</h4>
              <div class="panel-actions">
                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
              </div>
            </div>
            <div class="panel-body">
              <div id="grdSystemHpLog" runat="server"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </form>
</body>
</html>
