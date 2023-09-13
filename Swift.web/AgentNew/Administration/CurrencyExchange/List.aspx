<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.List" %>

<%@ Register Assembly="AjaxControlToolKit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
  <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="../../../ui/css/style.css" rel="stylesheet" />
  <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
  <script src="../../../js/functions.js" type="text/javascript"> </script>

  <script type="text/javascript">
    function amountKeyup(d) {
      let val = d.target.value;
      if (val != "") {
        val = val.replace(/,/g, '');
        val = val.replace(/[A-z^]/g, '');
        d.target.value = val;
      }
    }

    function UpdateRate(id) {
      if (confirm("Are you sure to update this record?")) {
        var cRate = GetValue("buyRate_" + id) == "" ? 0 : parseFloat(GetValue("buyRate_" + id));
        var pRate = GetValue("saleRate_" + id) == "" ? 0 : parseFloat(GetValue("saleRate_" + id));
        SetValueById("<%=rateId.ClientID %>", id, "");
        SetValueById("<%=buy.ClientID %>", cRate, "");
        SetValueById("<%=sale.ClientID %>", pRate, "");
        GetElement("<%=btnUpdate.ClientID %>").click();
      }
    }

    var oldId = 0;

    function KeepRowSelection(i, id) {
      if (oldId != 0 && oldId != id) {
        var j = GetValue(oldId);
        if (j % 2 == 1)
          GetElement("row_" + oldId).className = "oddbg";
        else
          GetElement("row_" + oldId).className = "evenbg";
        EnableDisableBtn("btnUpdate_" + oldId, true);
      }
      GetElement("row_" + id).className = "selectedbg";
      EnableDisableBtn("btnUpdate_" + id, false);
      oldId = id;
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
              <li class="active"><a href="List.aspx">Rate Update</a></li>
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
                  <h4 class="panel-title">Rate Update List
                  </h4>
                </div>
                <div class="panel-body">
                  <div class="form-group">
                    <table class="table table-responsive">
                      <tr>
                        <td>
                          <div id="add" runat="server" style="display: none;">
                            <table class="table table-responsive">
                              <tr>
                                <td valign="top">
                                  <asp:UpdatePanel ID="upnl1" runat="server">
                                    <ContentTemplate>
                                      <div class="cols-md-12">
                                        <table border="0" cellspacing="0" cellpadding="0" class="table">
                                          <colgroup>
                                            <caption>
                                              <tr>
                                                <td colspan="3">
                                                  <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
                                                  <asp:HiddenField ID="rateId" runat="server" />
                                                  <asp:HiddenField ID="buy" runat="server" />
                                                  <asp:HiddenField ID="sale" runat="server" />
                                                </td>
                                              </tr>
                                            </caption>
                                          </colgroup>
                                        </table>
                                      </div>
                                    </ContentTemplate>
                                  </asp:UpdatePanel>
                                </td>
                              </tr>
                            </table>
                          </div>
                        </td>
                      </tr>
                      <tr>
                        <td>
                          <div id="rpt_rate" runat="server" enableviewstate="false"></div>
                        </td>
                      </tr>
                    </table>
                  </div>
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
