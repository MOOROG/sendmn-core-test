<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchTxnDetail.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.SearchTxnDetail" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/js/Swift_grid.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_calendar.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

    <script language="javascript" type="text/javascript">
		


    function testApprove(id) {
      SetValueById("<% = hddTranNo.ClientID %>", id, false);
      GetElement("<% =testButton.ClientID %>").click();
    }




    </script>
    <style>
    td {
        text-align: center;
    }

  </style>
</head>
<body>

    <form id="form1" runat="server">

        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="SearchTxnDetail.aspx">Search Transaction Detail</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="Manage">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">
                                        <label>Search Transaction Detail</label>
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                                        <a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss=""></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-3">
                                                <label>Super Agent</label>
                                                <asp:DropDownList ID="sAgent" runat="server" AutoPostBack="true" CssClass="form-control" OnSelectedIndexChanged="sAgent_Change" >
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Control No</label>
                                                <asp:TextBox ID="tranNo" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                          <div class="col-md-3">
                                            <label>Balance</label>
                                            <asp:TextBox ID="balance" runat="server" CssClass="form-control"></asp:TextBox>
                                          </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-4">
                                                <asp:Button ID="btnSearch" runat="server" Text="Search Txn" CssClass="btn btn-primary m-t-25"
                                                    OnClick="btnSearch_Click" ValidationGroup="rpt" />
                                            </div>
                                        </div>
                                    </div>
                                    <div id="approveList" runat="server" class="col-sm-12">
                                        <div id="rptGrid" runat="server" class="col-sm-12" enableviewstate="false"></div>
                                    </div>
                                    <div id="selfTxn" runat="server" class="col-sm-12"></div>
                                    <br />
                                    <asp:Button ID="testButton" runat="server" Text="testButton" CssClass="btn btn-primary" Style="        display: none" OnClick="testBtn_Click" />
                                    <asp:HiddenField ID="hddTranNo" runat="server" />
                                    <asp:HiddenField ID="hdntabType" runat="server" />

                                    <div>
                                        <div id="txnSummary" runat="server" class="col-sm-12" enableviewstate="false"></div>
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

<script type="text/javascript">

	function SelectTab(obj) {
		document.getElementById('hdntabType').value = obj;
		if (obj == "a") {
			document.getElementById('appCnt').style.display = "block";
			document.getElementById('selfTxn').style.display = "none";
			document.getElementById('rptGrid').style.display = "block";
			document.getElementById("a").setAttribute("class", "selected");
			document.getElementById("s").setAttribute("class", "");
		}
		if (obj == "s") {
			document.getElementById('appCnt').style.display = "none";
			document.getElementById('selfCnt').style.display = "block";
			document.getElementById('rptGrid').style.display = "none";
			document.getElementById('selfTxn').style.display = "block";
			document.getElementById("s").setAttribute("class", "selected");
			document.getElementById("a").setAttribute("class", "");
		}

	}
</script>
