<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BranchCustomer.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.BranchCustomer" %>

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
  <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
  <script type="text/javascript">

    $(function () {
      $('.pop').on('click', function () {
        var imgPath = '<%=docPath%>' + '/customerIds/' + $(this).attr('mine');
        $('.imagepreview').attr('src', imgPath);
        $('#imagemodal').modal('show');
      });
    });

    /*
    $('#trslphotos').on('shown.bs.modal', function (a, b, c) {
      var clickedImageUrl = a.relatedTarget.childNodes[0].src;
      displayPhotos(clickedImageUrl);
    })

    function displayPhotos(url) {
      console.log(url);
      $('.modal-body img').attr('src', url);
      $('#trslphotos').modal();
    }
    */
    var notification;
    /*
    $(document).ready(function () {
      setInterval(function () {
        getErrorTrx();
      }, 30000);
    });
    */
    function createNotification(data) {

      var options = {
        body: data,
        vibrate: true
      };

      notification = new Notification("Алдаатай гүйлгээ үүссэн байна", options);
      /*
      setTimeout(() => {
        notification.close();
      }, 5 * 1000);
      
      notification.onclick = function () {
        window.open("http://www.Google.com/");
      };
      */
    }

    function notifyMe(data) {
      if (!("Notification" in window)) {
        //alert("This browser does not support desktop notification");
      }
      else if (Notification.permission === "granted") {
        createNotification(data);
      }
      else if (Notification.permission !== 'denied') {
        Notification.requestPermission(function (permission) {
          if (!('permission' in Notification)) {
            Notification.permission = permission;
          }
          if (permission === 'granted') {

            createNotification();
          }
        });
      }
    }

    function getErrorTrx() {
        $.ajax({
          type: "POST",
          contentType: "application/json; charset=utf-8",
          url: "../../../Autocomplete.asmx/GetErrorTransactionList",
          data: "",
          dataType: "json",
          success: function (data) {
            if (data.d != "") {
              notifyMe(data.d);
            }
          },
          error: function (result) {
            alert("Due to unexpected errors we were unable to load data");
          }
        });
    }

  </script>

</head>
<body>
  <form id="form1" runat="server">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <h1></h1>
            <ol class="breadcrumb">
              <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
              <li class="active"><a href="BranchCustomer.aspx">BranchCustomer</a></li>
            </ol>
          </div>
        </div>
      </div>
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

    <div class="modal fade" id="imagemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-body">
            <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
            <img src="" class="imagepreview" style="width: 100%;">
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" id="trslphotos" tabindex="-1" role="dialog" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true"></button>
            <h4 class="modal-title"></h4>
          </div>
          <div class="modal-body">
            <img src="" class="img-responsive">
          </div>
          <div class="modal-footer">
            <a class="carousel-control left" href="#recent-photos" data-slide="prev"><i class="glyphicon glyphicon-chevron-left"></i></a>
            <a class="carousel-control right" href="#recent-photos" data-slide="next"><i class="glyphicon glyphicon-chevron-right"></i></a>
          </div>
        </div>
      </div>
    </div>
  </form>
</body>
</html>
