<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="IndividualRiskAssessment.aspx.cs" Inherits="Swift.web.RiskBasedAssessment.IndividualRiskAssessment" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <style type="text/css">
        .auto-style1 {
            height: 23px;
        }

        .auto-style2 {
            height: 23px;
            width: 98px;
        }

        .auto-style3 {
            width: 98px;
        }

        .auto-style9 {
            position: relative;
            min-height: 1px;
            float: left;
            width: 100%;
            left: 0px;
            top: 0px;
            padding-left: 15px;
            padding-right: 15px;
        }

        .auto-style10 {
            height: 23px;
            width: 137px;
        }

        .auto-style11 {
            width: 137px;
        }

        .auto-style12 {
            border-top-left-radius: 3px;
            border-top-right-radius: 3px;
            position: relative;
            left: 0px;
            top: 0px;
            border-bottom: 1px solid transparent;
            padding: 10px 15px;
        }
    </style>

</head>
<body>
    <form id="form2" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="List.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="List.aspx">Risk Based Assessment</a></li>

                        </ol>
                    </div>
                </div>
            </div>
            <div class="rba-tab">
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li>
                            <a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">Risk Based Assessment List </a></li>
                        <li role="presentation" class="active"><a href="IndividualRiskAssessment.aspx">New Individual Txn Assessment</a></li>
                        <li><a href="PeriodicRiskAssessment.aspx">New Periodic Txn Assessment</a></li>
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="auto-style9">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Individual Txn Assessment</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle"></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-responsive table-striped table-bordered">
                                        <thead>
                                            <tr>

                                                <th class="auto-style1">
                                                    <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; width: 113pt" width="150">
                                                        <colgroup>
                                                            <col style="mso-width-source: userset; mso-width-alt: 5485; width: 113pt" width="150" />
                                                        </colgroup>
                                                        <tr height="20" style="height: 15.0pt">
                                                            <td class="xl65" height="20" width="150">Criteria</td>
                                                        </tr>
                                                    </table>
                                                </th>

                                                <th class="auto-style10">
                                                    <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; width: 58pt" width="77">
                                                        <colgroup>
                                                            <col style="mso-width-source: userset; mso-width-alt: 2816; width: 58pt" width="77" />
                                                        </colgroup>
                                                        <tr height="20" style="height: 15.0pt">
                                                            <td class="xl65" height="20" width="77">Condition</td>
                                                        </tr>
                                                    </table>
                                                </th>
                                                <th class="auto-style1">Criteria</th>
                                                <th class="auto-style2">Value</th>
                                                <th class="auto-style1"><strong>Weight</strong></th>

                                                <th class="auto-style1"><strong></strong></th>
                                            </tr>
                                        </thead>
                                        <tbody id="Tbody1" runat="server">
                                            <tr class="auto-style3">

                                                <td>


                                                    <asp:DropDownList runat="server" ID="Criteria" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="Criteria_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </td>

                                                <td class="auto-style11">
                                                    <asp:DropDownList runat="server" ID="Condition" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </td>

                                                <td>
                                                    <asp:DropDownList runat="server" ID="CriteriaCountry" CssClass="form-control">
                                                    </asp:DropDownList>
                                                    <asp:TextBox runat="server" ID="CriteriaDetail"></asp:TextBox></td>
                                                <td class="auto-style3">
                                                    <asp:TextBox runat="server" ID="Result"></asp:TextBox></td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="Weight"></asp:TextBox></td>

                                                <td>
                                                    <asp:Button runat="server" ID="btnSave" OnClick="btnSave_Click" class="btn btn-primary m-t-25" Text="Save" /></td>
                                            </tr>

                                        </tbody>
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
</html>
