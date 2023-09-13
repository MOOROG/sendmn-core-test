<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBACalculationDetails.aspx.cs"
    Inherits="Swift.web.Remit.RiskBaseAnalysis.RBACalculationDetails" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../Css/style.css" rel="Stylesheet" type="text/css" />
    <style type="text/css">
        .header
        {
            font-size: 20px;
            background: red;
            color: White;
            height: 40px;
        }
        .sub-header
        {
            font-size: 15px;
            background: black;
            color: White;
            height: 20px;
        }
        table
        {
          width:80%;
           border-collapse: collapse;
        }
        table, td, th
        {
            border: 1px solid black; 
        }
        .clear-fix
        {
            clear:both;
            height:15px;
        }
        
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <div class="breadCrumb">
            Risk Base Analysis » RBA Calculation Details</div>
        <div class="clear-fix"></div>
        <div style="margin-left:10px">
            <div>
            <table>
                <tr class="header">
                    <th nowrap="nowrap">
                        RBA Level:
                    </th>
                    <th nowrap="nowrap">
                        <asp:Label runat="server" ID="rbaLevel"></asp:Label>
                    </th>
                    <th nowrap="nowrap">
                        RBA Rating:
                    </th>
                    <th nowrap="nowrap">
                        <asp:Label runat="server" ID="rbaRating"></asp:Label>
                    </th>
                </tr>
                <tr>
                    <td>
                        Full Name:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="fullName"></asp:Label>
                    </td>
                    <td>
                        DOB:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="dob"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        Gender:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="gender"></asp:Label>
                    </td>
                    <td>
                        Native Country:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="nativeCountry"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        Id Type:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="idType"></asp:Label>
                    </td>
                    <td>
                        Id Number:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="idNumber"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        Country:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="country"></asp:Label>
                    </td>
                    <td>
                        State:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="state"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        City:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="city"></asp:Label>
                    </td>
                    <td>
                        Address:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="address"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td>
                        Mobile No:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="mobileNo"></asp:Label>
                    </td>
                    <td>
                        E-mail:
                    </td>
                    <td>
                        <asp:Label runat="server" ID="email"></asp:Label>
                    </td>
                </tr>
            </table>
        </div>
        <div class="clear-fix">
        </div>
        <div>
            <table>
                <tr class="header">
                    <th colspan="3">
                        RBA Calculation Summary
                    </th>
                </tr>
                <tr class="sub-header">
                    <th style="width: 253px;">
                        Description
                    </th>
                    <th>
                        Rating
                    </th>
                    <th>
                        Weight
                    </th>
                </tr>
                <tr>
                    <th>
                        Transaction Assesement
                    </th>
                    <td>
                        <asp:Label runat="server" ID="taRating"></asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="taWeight"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <th>
                        Periodic Assesement
                    </th>
                    <td>
                        <asp:Label runat="server" ID="paRating"></asp:Label>
                    </td>
                    <td>
                        <asp:Label runat="server" ID="paWeight"></asp:Label>
                    </td>
                </tr>
            </table>
        </div>
        <div class="clear-fix">
        </div>
        <div runat="server" id="rbaCsTa">
        </div>
        <div class="clear-fix">
        </div>
        <div runat="server" id="rbaCsPa">
        </div>
         <div class="clear-fix">
        </div>
      
        <div class="clear-fix">
        </div>
        </div>
        
    </div>
    </form>
</body>
</html>
