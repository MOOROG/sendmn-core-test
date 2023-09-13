<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RemitTxnSearch.aspx.cs" Inherits="Swift.web.AccountReport.TxnDocumentReport.RemitTxnSearch" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../ui/js/jquery.min.js"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../js/functions.js"></script>
    <script src="../../js/swift_calendar.js"></script>

    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =sfromDate.ClientID%>", "#<% =stoDate.ClientID%>", 1);
            ShowCalFromTo("#<% =tfromDate.ClientID%>", "#<% =ttoDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Remit Transaction Search</li>
                            <li class="active">Domestic</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">REMIT TRANSACTION SEARCH - DOMESTIC - SENDING AGENT
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Sending Agent:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="sendAgentddl" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <%--<td><% call CreateComboBoxREFDisplay ("agent_id", "Select agent_name,map_code from agentTable with (nolock) where AGENT_TYPE='sending' order by agent_name",  "",  "" ,"agent_name","map_code","All ")  %></td>--%>
                            <div class="form-group">
                                <div class="col-sm-2">
                                    <label>From Date: <span class="errormsg">*</span></label>
                                </div>
                                <div class="col-sm-4">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="sfromDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="sfromDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>

                                <div class="col-sm-2">
                                    <label>To Date: <span class="errormsg">*</span></label>
                                </div>
                                <div class="col-sm-4">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="stoDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="stoDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12 col-md-offset-2" style="left: 10px;">
                                    <input type="submit" name="Submit" value="Show" class="btn btn-primary" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">REMIT TRANSACTION SEARCH - DOMESTIC- RECEIVING AGENT
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Receiving Agent:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="recAgentddl" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <%--<td><% call CreateComboBoxREFDisplay ("agent_id", "Select agent_name,map_code from agentTable with (nolock) where AGENT_TYPE='sending' order by agent_name",  "",  "" ,"agent_name","map_code","All ")  %></td>--%>
                            <div class="form-group">
                                <div class="col-sm-2">
                                    <label>From Date: <span class="errormsg">*</span></label>
                                </div>
                                <div class="col-sm-4">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="tfromDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="tfromDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>

                                <div class="col-sm-2">
                                    <label>To Date: <span class="errormsg">*</span></label>
                                </div>
                                <div class="col-sm-4">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="ttoDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="ttoDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-12 col-md-offset-2" style="left: 10px;">
                                    <input type="submit" name="Submit" value="Show" class="btn btn-primary" />
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