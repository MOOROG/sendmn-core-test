<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RiaRate.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.TPRate.RiaRate" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <base id="Base1" target="_self" runat="server" />
  <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
  <link href="../../../ui/css/style.css" rel="stylesheet" />

  <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
  <script src="../../../js/functions.js" type="text/javascript"> </script>
  <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
  <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
  <script src="../../../js/jQuery/columnselector.js" type="text/javascript"></script>
  <script language="javascript" type="text/javascript">
    var p = 1;
  </script>
</head>

<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManger1" runat="server">
    </asp:ScriptManager>
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <h1></h1>
            <ol class="breadcrumb">
              <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li><a href="#" onclick="return LoadModule('account')">SETUP PROCESS</a></li>
              <li><a href="#" onclick="return LoadModule('account_report')">Exchange Rate</a></li>
              <li class="active"><a href="ExRateTreasury.aspx">ExRate Treasury- Manage</a></li>
            </ol>
          </div>
        </div>
      </div>
      <div class="listtabs">
        <ul class="nav nav-tabs">
          <div id="divTab" runat="server"></div>
        </ul>
      </div>
      <div class="tab-content">
        <div role="tabpanel" class="tab-pane active" id="list">
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites">
                <!-- Start .panel -->
                <div class="panel-heading">
                  <h4 class="panel-title">ExRate Treasury- Manage
                  </h4>
                </div>
                <div class="panel-body">
                  <table class="table table-responsive">
                    <tr>
                      <td>
                        <div id="paginDiv" runat="server"></div>
                        <div id="rpt_grid" runat="server" enableviewstate="false" class="responsive-table ">
                        </div>
                        <div id="divFixed" style="float:right">
                          <asp:Button ID="btnUpdateChanges" CssClass="btn btn-primary m-t-25" runat="server" Text="Update"
                            OnClick="btnUpdateChanges_Click" />
                          <cc1:ConfirmButtonExtender ID="btnUpdateChangescc" runat="server"
                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnUpdateChanges">
                          </cc1:ConfirmButtonExtender>
                        </div>
                        <asp:HiddenField ID="exRateTreasuryId" runat="server" />
                        <asp:HiddenField ID="tolerance" runat="server" />
                        <asp:HiddenField ID="hddCHoMargin" runat="server" />
                        <asp:HiddenField ID="hddCAgentMargin" runat="server" />
                        <asp:HiddenField ID="hddPHoMargin" runat="server" />
                        <asp:HiddenField ID="hddPAgentMargin" runat="server" />
                        <asp:HiddenField ID="sharingType" runat="server" />
                        <asp:HiddenField ID="sharingValue" runat="server" />
                        <asp:HiddenField ID="toleranceOn" runat="server" />
                        <asp:HiddenField ID="agentTolMin" runat="server" />
                        <asp:HiddenField ID="agentTolMax" runat="server" />
                        <asp:HiddenField ID="customerTolMin" runat="server" />
                        <asp:HiddenField ID="customerTolMax" runat="server" />
                        <asp:HiddenField ID="crossRate" runat="server" />
                        <asp:HiddenField ID="agentCrossRateMargin" runat="server" />
                        <asp:HiddenField ID="customerRate" runat="server" />
                        <asp:HiddenField ID="isUpdated" runat="server" />
                        <asp:HiddenField ID="hdnIsFw" runat="server" />
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
  </form>
</body>
<script type="text/javascript">

    function CalcCOffers(obj, id, cRateMaskMulAd, crossRateMaskAd) {
      var objid = obj.id;
      var cRate = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
      var cMargin = GetValue("cMargin_" + id) == "" ? 0 : parseFloat(GetValue("cMargin_" + id));
      var cOffer = cRate + cMargin;
      var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
      var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
      var currentValue = GetValue(objid + "_current");

      var pOffer = GetElement("pOffer_" + id, "").innerHTML == "" ? 0 : parseFloat(GetElement("pOffer_" + id, "").innerHTML);
      var pRate = GetElement("pRateLbl_" + id, "").innerHTML == "" ? 0 : parseFloat(GetElement("pRateLbl_" + id, "").innerHTML);

      if (checkRateCapping(obj, currentValue, cMin, cMax, cOffer) == 1)
        return false;

      var maxRate = pRate / cRate;
      maxRate = roundNumber(maxRate, crossRateMaskAd);

      cOffer = cRate + cMargin;
      var cusRate = pOffer / cOffer;
      cusRate = roundNumber(cusRate, 10);
      cOffer = roundNumber(cOffer, cRateMaskMulAd);

      SetValueById("cOffer_" + id,"", cOffer);
      SetValueById("customerRate_" + id, cusRate);
      SetValueById("maxCrossRate_" + id, maxRate);
      return true;
  }

  function CalcCusRate(obj, id, cRateMaskMulAd) {
    var objid = obj.id;
    var cRate = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
    var cMargin = GetValue("cMargin_" + id) == "" ? 0 : parseFloat(GetValue("cMargin_" + id));
    var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
    var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
    var currentValue = GetValue(objid + "_current");
    var pOffer = GetElement("pOffer_" + id, "").innerHTML == "" ? 0 : parseFloat(GetElement("pOffer_" + id, "").innerHTML);
    var cusRate = GetValue(objid) == "" ? 0 : parseFloat(GetValue(objid));

    cMargin = (pOffer / cusRate) - cRate;
    cMargin = roundNumber(cMargin, cRateMaskMulAd);
    cOffer = cRate + cMargin;
    cOffer = roundNumber(cOffer, cRateMaskMulAd);
    if (checkRateCapping(obj, currentValue, cMin, cMax, cOffer) == 1)
      return false;
    SetValueById("cOffer_" + id, "", cOffer);
    SetValueById("cMargin_" + id, cMargin);
    return true;
  }
</script>
</html>
