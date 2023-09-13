using System;
using System.Text;
using Swift.web.Library;
using System.Web.UI;

namespace Swift.web
{
    public partial class Dashboard : Page
    {
        SwiftLibrary sl = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
            {
                PopulateMenu();
            }
        }

        private void PopulateMenu()
        {
            var isMenuForLive = GetStatic.ReadWebConfig("isMenuForLive", "N");
            if (isMenuForLive.ToUpper()=="N")
            {
                PopulateDevelopmentMenu();
                return;
            }
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<div id=\"navbar-main\" class=\"navbar-collapse collapse\">");
            sb.AppendLine("<ul class=\"nav navbar-nav\">");
            sb.AppendLine("<li class=\"active\"><a href=\"Dashboard.aspx\">Dashboard</a></li>");
            sb.AppendLine("<li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">Administration  <span class=\"caret\"></span></a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/ApplicationUserSetup/List.aspx\">User Management</a></li>");
            //sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Applications Settings</a></li>");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/AgentSetup/List.aspx\">Agent Management</a></li>");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/ApplicationRoleSetup/List.aspx\">Role Management</a></li>");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/ApplicationLog/List.aspx\">Application Log</a></li>");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/ApplicationUserPool/List.aspx\">User Monitor</a></li>");
            //sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">DC Management</a></li>");
            //sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Site Maintenance</a></li>");
            //sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Utilities</a></li>");
            //sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Administration</a></li>");
            sb.AppendLine("</li>");
            sb.AppendLine("</ul></li>");
            sb.AppendLine("<li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">Security <span class=\"caret\"></span></a>");
            //sb.AppendLine("<ul class=\"dropdown-menu\"><li><a href=\"#\">System security</a></li><li><a href=\"#\">Sub menu 2</a></li></ul>");
            sb.AppendLine("</li><li class=\"dropdown\">");

            //////## REMITTANCE MENU GROUP 
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\"> Remittance  <span class=\"caret\"></span></a>");
            ////exchange rate
            //sb.AppendLine("<ul class=\"dropdown-menu\"><li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Exchange Rate</a>");
            //sb.AppendLine("<ul class=\"dropdown-menu\">");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/RateMask/List.aspx\" target=\"mainFrame\">Rate Mask</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/RateMask/CurrencyList.aspx\" target=\"mainFrame\">Cross Rate Decimal Mask</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Cost Rate Setup</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Exchange Rate Treasury</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Reports</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Agent Exchange Rate Menu</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Cost Margin Report</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Exchange Rate History</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Approve Exchange Rate Treasury</a></li>");
            //sb.AppendLine("</ul></li>");
            ////service charge
            //sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Service Charge & Commission</a>");
            //sb.AppendLine("<ul class=\"dropdown-menu\">");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Service Charge</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Intl Send Commission</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Intl Pay Commission</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Domestic Commission</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Commission Group Mapping</a></li>");
            //sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"#\">Agent Commission Rule</a></li>");
            //sb.AppendLine("</ul></li>");
            //sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Credit Risk Management</a></li><li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Reports</a>");
            //sb.AppendLine("<li><a href=\"#\">Transaction</a></li><li><a href=\"#\">Reports</a></li><li><a href=\"#\">Send Domestic</a></li><li><a href=\"#\">Pay Domestic</a></li></ul>");

            //## ACCOUNT MENU GROUP
            sb.AppendLine("</li><li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">Account <span class=\"caret\"></span></a>");
            sb.AppendLine("<ul class=\"dropdown-menu\"><li><a href=\"AccountSetting/CreateLedger/List.aspx\"  target=\"mainFrame\">  Create Account  </a></li><li><a href=\"AccountReport/AccountDetail/List.aspx\" target=\"mainFrame\">Account Details</a></li><li><a href=\"BillVoucher/VoucherEntry/List.aspx\" target=\"mainFrame\">Voucher Entry</a></li>");
            sb.AppendLine("<li><a href=\"BillVoucher/VoucherEdit/List.aspx\" target=\"mainFrame\">Edit Voucher</a></li>");
            sb.AppendLine("<li><a href=\"AccountReport/RemittanceVoucher/List.aspx\" target=\"mainFrame\">  Remittance Voucher  </a></li>");
            sb.AppendLine("<li><a href=\"/AccountReport/AccountStatement/List.aspx\" target=\"mainFrame\">Account Statement</a></li><li><a href=\"AccountReport/BalanceSheet/List.aspx\" target=\"mainFrame\">Balancesheet</a></li><li><a href=\"AccountReport/TrialBalance/List.aspx\" target=\"mainFrame\">Trail Balance</a></li>");
            sb.AppendLine("<li><a href=\"BillVoucher/VoucherReport/List.aspx\" target=\"mainFrame\"> Voucher Report</a></li><li><a href=\"AccountReport/DayBook/List.aspx\" target=\"mainFrame\">Daybook</a></li><li><a href=\"AccountReport/PLAccount/List.aspx\"  target=\"mainFrame\">  Profit and Loss  </a></li></ul>");

            //## COMPLIANCE MENU GROUP
            sb.AppendLine("</li><li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">Compliance <span class=\"caret\"></span></a>");
            //sb.AppendLine("<ul class=\"dropdown-menu\"><li><a href=\"#\">Compliance Rule Setup</a></li><li><a href=\"#\">OFAC Management</a></li></ul></li>");
            sb.AppendLine("</ul></div>");
            menu.InnerHtml = sb.ToString();
        }

        private void PopulateDevelopmentMenu()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<div id=\"navbar-main\" class=\"navbar-collapse collapse\">");
            sb.AppendLine("<ul class=\"nav navbar-nav\">");
            sb.AppendLine("<li class=\"active\"><a href=\"Dashboard.aspx\">Dashboard</a></li>");

            sb.AppendLine("<li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">Administration  <span class=\"caret\"></span></a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/ApplicationUserSetup/List.aspx\">User Management</a></li>");
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Applications Settings</a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/SwiftSystem/GeneralSetting/StaticData/List.aspx\" target=\"mainFrame\">Static Data</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/SwiftSystem/GeneralSetting/MessageSetting/ListNewsFeeder.aspx\" target=\"mainFrame\">Message Setting</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/SwiftSystem/GeneralSetting/PasswordFormat/PasswordFormat.aspx\" target=\"mainFrame\">Password and Security Policy</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/SwiftSystem/GeneralSetting/MessageSetting/emailServerList.aspx\" target=\"mainFrame\">Email Server Setup</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/SwiftSystem/GeneralSetting/FieldSetting/List.aspx\" target=\"mainFrame\">Field Setting</a></li>");
            sb.AppendLine("</ul></li>");

            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/AgentSetup/List.aspx\">Agent Management</a></li>");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/ApplicationRoleSetup/List.aspx\">Role Management</a></li>");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/ApplicationLog/List.aspx\">Application Log</a></li>");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/ApplicationUserPool/List.aspx\">User Monitor</a></li>");
            sb.AppendLine("<li class=\"dropdown\"><a tabindex=\"-1\" target=\"mainFrame\" href=\"SwiftSystem/UserManagement/AgentUserSetup/List.aspx\">Agent User Setup</a></li>");
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">DC Management</a></li>");
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Site Maintenance</a></li>");
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Utilities</a></li>");
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Administration</a>");
            //adminstration
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Administration/GroupLocationMap/List.aspx\" target=\"mainFrame\">Location and Group Mapping</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Administration/AgentGroupSetup/List.aspx\" target=\"mainFrame\">Agent and Group Mapping</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Administration/CountrySetup/List.aspx\" target=\"mainFrame\">Country Setup</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Administration/CurrencySetup/List.aspx\" target=\"mainFrame\">Currency Setup</a></li>");
            sb.AppendLine("</ul></li>");

            sb.AppendLine("</ul></li>");
            sb.AppendLine("<li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">System security<span class=\"caret\"></span></a>");
            sb.AppendLine("<ul class=\"dropdown-menu\"><li><a href=\"/SwiftSystem/Notification/AppException/List.aspx\" target=\"mainFrame\" >Error Logs</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/ApplicationLogs/TransactionViewLog.aspx\" target=\"mainFrame\" > Transaction View Log</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/LoginLogs/List.aspx\" target=\"mainFrame\" >Login Logs</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/ApplicationLogs/List.aspx\" target=\"mainFrame\" >Application Logs</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/PwdChangedLogs/List.aspx\" target=\"mainFrame\" >Pwd Changed Logs</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/CommissionLogs/List.aspx\" target=\"mainFrame\" >Commission Logs</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/ExchangeRateLogs/List.aspx\" target=\"mainFrame\" >Exchange Rate Logs</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/FraudAccessMonitoring/List.aspx\" target=\"mainFrame\" > Fraud Access Monitoring</a></li>");
            sb.AppendLine("<li><a href=\"/Remit/Transaction/Reports/FraudAnalysis/Manage.aspx\" target=\"mainFrame\" > Fraud Analysis</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/TroubleTicket/UnResolvedList.aspx\" target=\"mainFrame\" >Trouble Ticket Resolve</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/TroubleTicket/Manage.aspx\" target=\"mainFrame\" > Trouble Ticket Report</a></li>");
            sb.AppendLine("<li><a href=\"/SwiftSystem/Notification/ApplicationLogRpt/Manage.aspx\" target=\"mainFrame\" >  Tran View Report</a></li>");
       
           
            sb.AppendLine("</ul></li><li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\"> Remittance  <span class=\"caret\"></span></a>");
            //exchange rate
            sb.AppendLine("<ul class=\"dropdown-menu\"><li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Exchange Rate</a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/RateMask/List.aspx\" target=\"mainFrame\">Rate Mask</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/CrossRateDecimalMask/List.aspx\" target=\"mainFrame\">Cross Rate Decimal Mask</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/AgentRateSetup/List.aspx\" target=\"mainFrame\">Cost Rate Setup</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/ExRateTreasury/List.aspx\" target=\"mainFrame\">Exchange Rate Treasury</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/Reports/List.aspx\" target=\"mainFrame\">Reports</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/AgentExRateMenu/List.aspx\" target=\"mainFrame\">Agent Exchange Rate Menu</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/Reports/ForexReport.aspx\" target=\"mainFrame\">Cost Margin Report</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/Reports/HistoryReport.aspx\" target=\"mainFrame\">Exchange Rate History</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ExchangeRate/ExRateTreasury/ApproveListOnly.aspx\" target=\"mainFrame\">Approve Exchange Rate Treasury</a></li>");
            sb.AppendLine("</ul></li>");
            //service charge
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Service Charge & Commission</a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ServiceCharge_Commission/ServiceCharge/List.aspx\" target=\"mainFrame\">Service Charge</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ServiceCharge_Commission/CommissionAgent/Send/List.aspx\" target=\"mainFrame\">Intl Send Commission</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ServiceCharge_Commission/CommissionAgent/Pay/List.aspx\" target=\"mainFrame\">Intl Pay Commission</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ServiceCharge_Commission/CommissionDomestic/List.aspx\" target=\"mainFrame\">Domestic Commission</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ServiceCharge_Commission/CommissionGroupMapping/CommissionPackage.aspx\" target=\"mainFrame\">Commission Group Mapping</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/ServiceCharge_Commission/AgentCommissionRule/List.aspx\" target=\"mainFrame\">Agent Commission Rule</a></li>");
            sb.AppendLine("</ul></li>");
           //Credit Risk Management 
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Credit Risk Management</a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/TransactionLimit/Countrywise/List.aspx\" target=\"mainFrame\">Country Per Transaction Limit</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/TransactionLimit/Agentwise/List.aspx\" target=\"mainFrame\">Agent Per Transaction Limit</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/CreditLimit/List.aspx\" target=\"mainFrame\">Credit Limit</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/CreditSecurity/ListAgent.aspx\" target=\"mainFrame\">Credit Security</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/UserTopUpLimit/List.aspx\" target=\"mainFrame\">User Top-Up Limit</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/BalanceTopUp/List.aspx\" target=\"mainFrame\"> Balance Top Up</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/TopUpApprove/List.aspx\" target=\"mainFrame\">Balance Top Up Approve</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/ExtraLimit/ApproveList.aspx\" target=\"mainFrame\">Extra Limit Approve</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/Reports/CreditSecurityRPT.aspx\" target=\"mainFrame\">Credit Security Report</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement/Transaction/Agent/FundTransfer/List.aspx\" target=\"mainFrame\">Deposit Slip Approve</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/CreditRiskManagement//DomesticOperation/UserWiseTxnLimit/List.aspx\" target=\"mainFrame\"> User Wise Txn Limit</a></li>");
            sb.AppendLine("</ul></li>");
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Reports</a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Transaction/Reports/Transaction/Manage.aspx\" target=\"mainFrame\"> Transaction Report</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Transaction/Reports/TranAnalysisRpt/ManageDomestic.aspx\" target=\"mainFrame\"> Transaction Analysis Report</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Transaction/Reports/RemittancePayableRpt/Manage.aspx\" target=\"mainFrame\"> Remittance Payble Report</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Transaction/Reports/AgentStmtReport.aspx\" target=\"mainFrame\"> Agent Statement Report</a></li>");
             sb.AppendLine("</ul></li>");
       
           
            //Transaction
            //sb.AppendLine("<li><a href=\"#\">Transaction</a></li><li>");
            sb.AppendLine("<li class=\"dropdown-submenu\"><a tabindex=\"-1\" href=\"#\">Transaction</a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"Remit/Transaction/AdminTransaction/Pay/PaySearch.aspx\" target=\"mainFrame\">Pay Transaction</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"Remit/Transaction/Cancel/Cancel.aspx\" target=\"mainFrame\">Cancel Transaction</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"Remit/Transaction/Modify/ModifyTran.aspx\" target=\"mainFrame\">Modify Transaction</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"Remit/Transaction/Approve/Manage.aspx\" target=\"mainFrame\">Approve Transaction</a></li>");
            sb.AppendLine("<li class=\"submenu\"><a tabindex=\"-1\" href=\"/Remit/Transaction/Reports/SearchTransaction.aspx\" target=\"mainFrame\"> Search Transaction</a></li>");
     
            sb.AppendLine("</ul></li>");

            sb.AppendLine("<li><a href=\"#\">Send Domestic</a></li><li><a href=\"#\">Pay Domestic</a></li></ul>");
            sb.AppendLine("</li><li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">Account <span class=\"caret\"></span></a>");
            sb.AppendLine("<ul class=\"dropdown-menu\"><li><a href=\"AccountSetting/CreateLedger/List.aspx\"  target=\"mainFrame\">  Create Account  </a></li><li><a href=\"AccountReport/AccountDetail/List.aspx\" target=\"mainFrame\">Account Details</a></li><li><a href=\"BillVoucher/VoucherEntry/List.aspx\" target=\"mainFrame\">Voucher Entry</a></li>");
            sb.AppendLine("<li><a href=\"BillVoucher/VoucherEdit/List.aspx\" target=\"mainFrame\">Edit Voucher</a></li>");
            sb.AppendLine("<li><a href=\"AccountReport/RemittanceVoucher/List.aspx\" target=\"mainFrame\">  Remittance Voucher  </a></li>");
            sb.AppendLine("<li><a href=\"/AccountReport/AccountStatement/List.aspx\" target=\"mainFrame\">Account Statement</a></li><li><a href=\"AccountReport/BalanceSheet/List.aspx\" target=\"mainFrame\">Balancesheet</a></li><li><a href=\"AccountReport/TrialBalance/List.aspx\" target=\"mainFrame\">Trail Balance</a></li>");
            sb.AppendLine("<li><a href=\"BillVoucher/VoucherReport/List.aspx\" target=\"mainFrame\"> Voucher Report</a></li><li><a href=\"AccountReport/DayBook/List.aspx\" target=\"mainFrame\">Daybook</a></li><li><a href=\"AccountReport/PLAccount/List.aspx\"  target=\"mainFrame\">  Profit and Loss  </a></li></ul>");
            sb.AppendLine("</li>");

            sb.AppendLine("<li class=\"dropdown\">");
            sb.AppendLine("<a href=\"#\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" role=\"button\" aria-haspopup=\"true\" aria-expanded=\"false\">Compliance <span class=\"caret\"></span></a>");
            sb.AppendLine("<ul class=\"dropdown-menu\">");
            sb.AppendLine("<li><a href=\"#\">Compliance Rule Setup</a></li>");
            sb.Append("<li><a href=\"#\">OFAC Management</a></li>");
            sb.Append("</ul></li>");


            sb.AppendLine("</ul> </div>");
            menu.InnerHtml = sb.ToString();
        }

        private void LoadFrame(string url = "")
        {
            mainFrame.Attributes.Add("src", url);
        }
    }
}