<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ListCashCode.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationRoleSetup.ListCashCode" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
 <base id="Base1" runat="server" target="_self" />
 <script src="/js/swift_grid.js" type="text/javascript"> </script>
 <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
 <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
 <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
 <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
 <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
 <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
 <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
 <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
 <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
 <script src="/js/functions.js" type="text/javascript"> </script>
 <script type="text/javascript" src="/js/swift_calendar.js"></script>
 <script type="text/javascript" src="/js/swift_autocomplete.js"></script>
 <script type="text/javascript" src="/ui/js/bootstrap-datepicker.js"></script>
 <script type="text/javascript" src="/ui/js/pickers-init.js"></script>
 <script type="text/javascript" src="/ui/js/jquery-ui.min.js"></script>
</head>
<body>

 <form id="form1" runat="server">
  <asp:HiddenField ID="isActive" runat="server" />
  <asp:HiddenField ID="rowId" runat="server" />
  <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
  <div class="page-wrapper">
   <!-- end .page title-->
   <div class="report-tab">
    <!-- Tab panes -->
    <div class="tab-content">
     <div role="tabpanel" class="tab-pane active" id="list">
      <div class="row">
       <div class="col-md-12">
        <div class="panel panel-default ">
         <!-- Start .panel -->
         <div class="panel-heading">
          <h4 class="panel-title">Cash Request List</h4>
          <div class="panel-actions">
           <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
           <%--<a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
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

 </form>
 <script type="text/javascript">
  $(document).ready(function () {
   $('.Y').hide();
  })

  function EnableDisable(id, controlNo, state) {
   var verifyText = 'Are you sure to enable for txn ' + controlNo + '?';
   if (id != '') {
    $('#isActive').val('Y');
    $('#rowId').val(id);
    if (state == 'Y') {
     verifyText = 'Are you sure to disable for txn ' + controlNo + '?';
     $('#isActive').val('N');
    }
    if (confirm(verifyText)) {
     $('#btnUpdate').click();
    }
   }
  }

  $(function () {
   $('.pop').on('click', function () {
    var imgPath = '<%=docPath%>' + '/customerIds/' + $(this).attr('mine');
    $('.imagepreview').attr('src', imgPath);
    $('#imagemodal').modal('show');
   });
  });


 </script>
</body>
</html>
