using Newtonsoft.Json;
using Swift.DAL.OnlineAgent;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace Swift.web.KJBank.CustomerSetup
{
    public partial class ModifyCustomer : System.Web.UI.Page
    {
        private const string GridName = "grid_kjcustomer";
        private const string ViewFunctionId = "20134000";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            DeleteRow();
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
            _grid.AllowDelete = true;
            _grid.DeleteText = "Modify";
            _grid.DeleteAlertText = "Are you sure to modify the detail?";

            _grid.AllowCustomLink = true;
            _grid.CustomLinkText = "<a href = \"ResetPassword.aspx?customerId=@customerId\"\"><img src=\"" + GetStatic.GetUrlRoot() + "/images/icon_reset.gif\" border=0 title=\"Reset Password\" alt=\"Reset Password\" /></a>&nbsp;&nbsp;";
            _grid.CustomLinkVariables = "customerId";
            string sql = "EXEC [proc_online_core_customerSetup] @flag = 'modify-list' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            var dr = _cd.GetCustomerForModification(GetStatic.GetUser(), id);

            /*
             * @Max - 2018.09
             * 파트너서비스 등록
             * */
            var requestObj = new PartnerServiceAccountRequest()
            {
                //삭제(03)인지, 수정(02)인지 확인해야 함..
                processDivision = "02",
                institution = dr["bankCode"].ToString(),
                depositor = dr["CustomerBankName"].ToString(),
                no = dr["bankAccountNo"].ToString(),
                virtualAccountNo = dr["walletAccountNo"].ToString(),
                obpId = dr["obpId"].ToString()
            };

            var idNumber = dr["idNumber"].ToString().Replace("-", "");

            //주민번호
            if (dr["idType"].ToString() == "8008")
            {
                requestObj.realNameDivision = "01";
                requestObj.realNameNo = idNumber;
            }
            //외국인등록번호
            else if (dr["idType"].ToString() == "1302")
            {
                requestObj.realNameDivision = "02";
                requestObj.realNameNo = idNumber;
            }
            //여권번호는 조합주민번호로 변경
            else if (dr["idType"].ToString() == "10997")
            {
                requestObj.realNameDivision = "04";

                //조합주민번호(생년월일-성별-국적-여권번호(마지막5자리))
                requestObj.realNameNo = String.Format("{0}{1}{2}{3}",
                                            dr["dobYMD"].ToString(),
                                            dr["genderCode"].ToString(),
                                            dr["nativeCountryCode"].ToString(),
                                            idNumber.Substring(idNumber.Length - 5));
            }

            var reqRealName = new RealNameRequest()
            {
                institution = dr["bankCode"].ToString(),
                no = dr["bankAccountNo"].ToString(),
                realNameDivision = requestObj.realNameDivision,
                realNameNo = requestObj.realNameNo
            };

            string requestBody = JsonConvert.SerializeObject(reqRealName);
            var response = KJBankAPIConnection.GetRealNameCheck(requestBody);

            //var response = KJBankAPIConnection.GetAccountDetailKJBank(obj.no, obj.institution);

            response.Msg = response.Msg.Split(':')[1];
            response.Msg = response.Msg.Replace("}", "");
            response.Msg = response.Msg.Trim();
            requestObj.depositor = response.Msg;

            if (response.ErrorCode == "0")
            {
                _cd.UpdateCustomer(GetStatic.GetUser(), id, requestObj.depositor);
                SendNotificationToKjBank(requestObj);
            }

            //GetStatic.AlertMessage(Page,dbResult.Msg);
        }

        /*
         * @Max - 2018.09
         * 파트너서비스 정보등록
         * */

        private void SendNotificationToKjBank(PartnerServiceAccountRequest obj)
        {
            string body = new JavaScriptSerializer().Serialize((obj));
            var resp = KJBankAPIConnection.CustomerRegistration(body);
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