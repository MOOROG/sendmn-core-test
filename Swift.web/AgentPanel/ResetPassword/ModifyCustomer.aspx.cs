using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentPanel.ResetPassword
{
    public partial class ModifyCustomer : System.Web.UI.Page
    {
        private const string GridName = "grid_publickjcustomer";
        private const string ViewFunctionId = "40122000";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            swiftLibrary.CheckSession();
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                //Authenticate();
            }
           // DeleteRow();
            LoadGrid();
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }


        private void LoadGrid()
        {

            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_online_approve_Customer] @flag = 'searchCriteria'"),
                                     new GridFilter("searchValue", "Search Value", "T"),
                                     new GridFilter("fromDate", "Registered From", "d"),
                                     new GridFilter("toDate", "Registered To", "d"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),                                      
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("fullName", "Customer Name", "", "T"),
                                      new GridColumn("mobile", "Mobile", "", "T"),
                                      new GridColumn("idtype", "ID Type", "", "T"),
                                      new GridColumn("idNumber", "ID No", "", "T"),
                                      new GridColumn("createdDate","Regd. Date","","D"),                                      
                                      new GridColumn("bankName","Bank Name","","T")  ,                                    
                                      new GridColumn("bankAccountNo","Account Number","","T") ,                                     
                                      new GridColumn("walletAccountNo","Virtual Number","","T")                                      
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "customerId";
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.AllowCustomLink = true;
            _grid.CustomLinkText = "<a href = \"ResetPassword.aspx?customerId=@customerId\"\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/icon_reset.gif\" border=0 title=\"Reset Password\" alt=\"Reset Password\" /></a>&nbsp;&nbsp;";
            _grid.CustomLinkVariables = "customerId";
            string sql = "EXEC [proc_online_core_customerSetup] @flag = 'modify-list' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
        //private void DeleteRow()
        //{
        //    string id = _grid.GetCurrentRowId(GridName);
        //    if (string.IsNullOrEmpty(id))
        //        return;
        //    var dr = _cd.GetCustomerForModification(GetStatic.GetUser(), id);

        //    var obj = new PartnerServiceModificationRequest()
        //    {
        //        processDivision = "02",
        //        institution = dr["bankCode"].ToString(),
        //        depositor = dr["CustomerBankName"].ToString(),
        //        no = dr["bankAccountNo"].ToString(),
        //        virtualAccountNo = dr["walletAccountNo"].ToString(),
        //        obpId = dr["obpId"].ToString()
        //    };

        //    var response = KJBankAPIConnection.GetAccountDetailKJBank(obj.no, obj.institution);
        //    obj.depositor = response.Msg;

        //    if (response.ErrorCode == "0")
        //    {
        //        _cd.UpdateCustomer(GetStatic.GetUser(), id, obj.depositor);
        //        SendNotificationToKjBank(obj);
        //    }

        //    //GetStatic.AlertMessage(Page,dbResult.Msg);
        //}
        private void SendNotificationToKjBank(PartnerServiceModificationRequest obj)
        {
            string body = new JavaScriptSerializer().Serialize((obj));
            var resp = KJBankAPIConnection.PostToKJBank(body);
            if (!string.IsNullOrWhiteSpace(resp.Id))
            {
                GetStatic.AlertMessage(Page, "Customer Detail updated");
            }
        }

        //protected void btnReset_Click(object sender, EventArgs e)
        //{
        //    string customerId = hddCustomerId.Value;
        //    DataRow _res = _cd.ResetPassword(GetStatic.GetUser(), customerId);
        //    if (_res == null)
        //    {
        //        return;
        //    }
        //    if (_res["ErrorCode"].ToString() == "0")
        //    {
        //        string msgBody = GetPassResetMsgBody(_res);
        //        string msgSubject = "Customer verification approved";
        //        string toEmail = _res["email"].ToString();
        //        Task.Factory.StartNew(() => { SendEmail(msgSubject, msgBody, toEmail); });
        //    }
        //}

        //private void SendEmail(string msgSubject, string msgBody, string toEmailId)
        //{
        //    SmtpMailSetting mail = new SmtpMailSetting
        //    {
        //        MsgBody = msgBody,
        //        MsgSubject = msgSubject,
        //        ToEmails = toEmailId
        //    };

        //    mail.SendSmtpMail(mail);
        //}

        //private string GetPassResetMsgBody(DataRow _res)
        //{
        //    var mailBody = "Dear Mr./Ms./Mrs. " + _res["fullName"].ToString() + ",";

        //    mailBody += "<br>Your new password is " + _res["Password"].ToString() + ".";
        //    mailBody +=
        //        "<br><br>If you need further assistance kindly reply this email or call us at 02-3673-5559. or visit our website <a href=\"http://www.gmeremit.com\"> www.gmeremit.com </a>";
        //    mailBody +=
        //        "<br><br><br>We look forward to provide you excellent service.";
        //    mailBody +=
        //       "<br><br>Thank You.";
        //    mailBody +=
        //       "<br><br><br>Regards,";
        //    mailBody +=
        //       "<br>GME Online Team";
        //    mailBody +=
        //       "<br>Head Office";
        //    mailBody +=
        //       "<br>325, Jong-ro, ";
        //    mailBody +=
        //       "<br>Jongno-gu, 03104 Seoul, Korea ";
        //    mailBody +=
        //       "<br>Phone number 02-3673-5559 ";
        //    return mailBody;
        //}
    }
}