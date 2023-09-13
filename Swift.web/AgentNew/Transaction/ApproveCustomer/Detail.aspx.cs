using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Transaction.ApproveCustomer
{
    public partial class Detail : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private string GMEWalletApiBaseUrl = GetStatic.ReadWebConfig("KJURL", "");
        private string secretKey = GetStatic.ReadWebConfig("KJsecretKey", "");

        private const string ViewFunctionId = "20314000";

        private const string PartnerServiceKey = "1234";
        private const string kycVerificationCode = "0";
        private string m = GetStatic.ReadQueryString("m", "");
        private string id = GetStatic.ReadQueryString("customerId", "");

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            approve.Visible = false;
            if (!IsPostBack)
            {
                Authenticate();

                if (id != "")
                {
                    if (m != "")
                    {
                        approve.Visible = true;
                    }
                    PopulateCustomerDetails(id);
                }
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateCustomerDetails(string id)
        {
            var dataSet = _cd.GetVerifyCustomerDetailsNew(id, GetStatic.GetUser());
            var dr = dataSet.Tables[1].Rows[0];
            var registerDate = dr["createdDate"].ToString();
            hdnCustomerId.Value = dr["customerId"].ToString();
            txtMembershipNo.Text = dr["membershipId"].ToString();
            txtCustomerType.Text = dr["customerType"].ToString();
            fullName.Text = dr["fullName"].ToString();
            hdnAccountName.Value = fullName.Text;
            genderList.Text = dr["gender"].ToString();
            countryList.Text = dr["country"].ToString();
            addressLine1.Text = dr["address"].ToString();
            postalCode.Text = dr["postalCode"].ToString();
            city.Text = dr["city"].ToString();
            email.Text = dr["email"].ToString();
            phoneNumber.Text = dr["telNo"].ToString();
            mobile.Text = dr["mobile"].ToString();
            nativeCountry.Text = dr["nativeCountry"].ToString();
            dob.Text = dr["dob"].ToString();
            occupation.Text = dr["occupation"].ToString();
            IssueDate.Text = dr["idIssueDate"].ToString();
            ExpireDate.Text = dr["idExpiryDate"].ToString();
            idType.Text = dr["idType"].ToString();
            verificationTypeNo.Text = dr["idNumber"].ToString();
            bankName.Text = dr["bankName"].ToString();
            accountNumber.Text = dr["bankAccountNo"].ToString();
            postalCode.Text = dr["zipcode"].ToString();
            hdnAccountNumber.Value = accountNumber.Text;

            hdnIdTypeCode.Value = dr["idTypeCode"].ToString();
            hdnGenderCode.Value = dr["genderCode"].ToString();
            hdnNativeCountryCode.Value = dr["nativeCountryCode"].ToString();
            hdnDobYmd.Value = dr["dobYMD"].ToString();
            var documentDetails = _cd.GetDocumentByCustomerId(id);
            StringBuilder imageHtml = new StringBuilder();
            if (documentDetails != null)
            {
                foreach (DataRow item in documentDetails.Rows)
                {
                    showDocDiv.Visible = true;
                    string imageUrl = "";
                    string docName = "";

                    if (item["documentType"].ToString() == "0")
                    {
                        docName = "Signature";
                        imageUrl = "/Handler/CustomerSignature.ashx?registerDate=" + Convert.ToDateTime(registerDate).ToString("yyyy-MM-dd") + "&customerId=" + hdnCustomerId.Value + "&membershipNo=" + txtMembershipNo.Text;
                    }
                    else
                    {
                        docName = item["documentName"].ToString();
                        imageUrl = "/AgentNew/GetFileView.ashx?imageName=" + item["fileName"] + "&customerId=" + txtMembershipNo.Text + "&fileType=" + item["fileType"];
                    }

                    imageHtml.Append("<div class=\"col-md-3\"><div class=\"form-group\"><div class=\"col-md-12\">");
                    imageHtml.Append("<label>" + docName + "</label>");
                    imageHtml.Append("</div>");
                    imageHtml.Append("<div class=\"col-md-12\">");
                    imageHtml.Append("<img src=\"" + imageUrl + "\" height=\"150\" width=\"200\"  onclick=\'showImage(this);\'/>");
                    imageHtml.Append("</div>");
                    imageHtml.Append("</div>");
                    imageHtml.Append("</div>");
                }
                docDiv.InnerHtml = imageHtml.ToString();
            }
        }

        protected void approve_Click(object sender, EventArgs e)
        {
            if (m == "ap")
            {
                var ds = _cd.ApprovePending(id, GetStatic.GetUser(), lblBankAcName.Text);

                DbResult dbRes = _cd.ParseDbResult(ds.Tables[0]);

                if (dbRes.ErrorCode == "1")
                {
                    msg.InnerText = dbRes.Msg;
                    msg.Visible = true;
                }
                else
                {
                    msg.Visible = false;
                    if (dbRes.ErrorCode.Equals("0"))
                    {
                        string username = ds.Tables[1].Rows[0]["username"].ToString();
                        string pwd = ds.Tables[1].Rows[0]["password"].ToString();
                        string fullName = ds.Tables[1].Rows[0]["fullName"].ToString();

                        string msgBody = GetApprovedCustomerMsgBody(username, pwd);
                        string msgSubject = "Customer Approved Notification";
                        var idNumber = ds.Tables[1].Rows[0]["idNumber"].ToString().Replace("-", "");

                        GetStatic.SetMessage(dbRes.ErrorCode, dbRes.Msg);
                        Task.Factory.StartNew(() => { SendEmail(msgSubject, msgBody, username); });
                        Response.Redirect("ApprovedList.aspx");
                    }
                }

                GetStatic.AlertMessage(Page, "Approval Failed, Account Registration Fail error.");
            }
            else if (m == "vp")
            {
                var dbResult = _cd.VerifyPending(id, GetStatic.GetUser());
                if (dbResult.ErrorCode.Equals("0"))
                {
                    GetStatic.SetMessage(dbResult);
                    Response.Redirect("List.aspx");
                }

                GetStatic.AlertMessage(Page, dbResult.Msg);
            }
        }
        protected void reject_Click(object sender, EventArgs e)
        {
            if (m == "ap")
            {
                var ds = _cd.RejectPending(id, GetStatic.GetUser(), lblBankAcName.Text);

                DbResult dbRes = _cd.ParseDbResult(ds.Tables[0]);

                if (dbRes.ErrorCode == "1")
                {
                    msg.InnerText = dbRes.Msg;
                    msg.Visible = true;
                }
                else
                {
                    msg.Visible = false;
                    if (dbRes.ErrorCode.Equals("0"))
                    {
                        string username = ds.Tables[1].Rows[0]["username"].ToString();
                        string pwd = ds.Tables[1].Rows[0]["password"].ToString();
                        string fullName = ds.Tables[1].Rows[0]["fullName"].ToString();

                        string msgBody = GetRejectedCustomerMsgBody(username, pwd);
                        string msgSubject = "Customer Rejected Notification";
                        var idNumber = ds.Tables[1].Rows[0]["idNumber"].ToString().Replace("-", "");

                        GetStatic.SetMessage(dbRes.ErrorCode, dbRes.Msg);
                        Task.Factory.StartNew(() => { SendEmail(msgSubject, msgBody, username); });
                        Response.Redirect("ApprovedList.aspx");
                    }
                }

                GetStatic.AlertMessage(Page, "Reject Failed, Account Registration Fail error.");
            }
        }

        private void SendEmail(string msgSubject, string msgBody, string toEmailId)
        {
            SmtpMailSetting mail = new SmtpMailSetting
            {
                MsgBody = msgBody,
                MsgSubject = msgSubject,
                ToEmails = toEmailId
            };
            mail.SendSmtpMail(mail/*GetStatic.GetAppRoot()+"/SampleFile/GME-TermsAndConditions.pdf"*/);
        }

        public string GetApprovedCustomerMsgBody(string username, string pwd)
        {
            var mailBody = "Dear Mr./Ms./Mrs. " + fullName.Text + ",";
            mailBody +=
                    "<br><br>Thank you for registering with "+GetStatic.ReadWebConfig("jmeName", "") +" Online Remittance. Please find your username below:";
            mailBody += "<br><br>Username: " + username;
            mailBody += "<br>Password: " + pwd;
            mailBody +=
                "<br><br>Your login with "+ GetStatic.ReadWebConfig("jmeName", "") + "Remit is checked and validated. You can now start sending remittance to your desired country.";
            mailBody +=
                "<br><br><br>PROCESS TO TRANSFER FUNDS:";
            //mailBody += "<br>• Your unique account number with JME is " + account + ", it is displayed in your login window all the time";
            mailBody += "<br>• Please make your desired transfer in your "+ GetStatic.ReadWebConfig("jmeName", "") + " account through your nearest ATM or ebanking";
            mailBody += "<br>• Login to <a href=\"https://japanremit.com\"> www.japanremit.com </a> and click send money. Please enter your beneficiary details to transfer funds";
            mailBody += "<br>• For cash transfers, you will receive a PIN Code after successfully submitting your details. For account transfers to your desired country, "+ GetStatic.ReadWebConfig("jmeName", "") + " will process the transactions to be deposited within 24 hours (deposit time may vary where beneficiary banks are not easily accessible)";
            mailBody += "<br>• All cash transfers has to be verified by "+ GetStatic.ReadWebConfig("jmeName", "") + " and are ready to collect at your location within an hour";

            mailBody += "<br><br>Note: *All Receipts generated after successful transfers are also sent to your registered email.";
            mailBody += "<br><br><br>*Money transfer limit per transaction is USD 3,000 and USD 20,000 for 1 year.";
            mailBody +=
                "<br><br>If you need further assistance kindly reply this email or call us at <br/>";
            //mailBody += @"Tel. 1588 6864 (Multi-language Support) <br/>
            //                010 2959 6864 (Nepal) <br/>
            //                010 2930 6864 (Vietnam)<br/>
            //                010 2971 6864 (Cambodia)<br/>
            //                010 2970 6864 (Philippines)<br/>
            //                010 2837 6864 (Sri lanka)<br/>
            //                010 2760 6864 (Pakistan/India)<br/>
            //                010 2967 6864 (Bangladesh)<br/>
            //                010 3015 6864 (Uzbekistan)<br/>";

            mailBody += "or visit our website <a href=\"https://japanremit.com\"> www.japanremit.com </a>";

            mailBody +=
                "<br><br><br>We look forward to provide you excellent service.";
            mailBody +=
               "<br><br>Thank You.";
            mailBody +=
               "<br><br><br>Regards,";
            mailBody +=
               "<br>"+ GetStatic.ReadWebConfig("jmeName", "") + " Online Team";
            mailBody +=
               "<br>Head Office";
            mailBody +=
               "<br>Post Code: 169-0073 Omori Building 4F(AB), Hyakunincho 1-10-7, Shinjuku-ku, Tokyo, Japan ";
            mailBody +=
               "<br>Phone number 08034104278 ";
            return mailBody;
        }


        public string GetRejectedCustomerMsgBody(string username, string pwd)
        {
            var mailBody = "Dear Mr./Ms./Mrs. " + fullName.Text + ",";
            mailBody +=
                    "<br><br>Thank you for registering with "+ GetStatic.ReadWebConfig("copyRightName", "") +" Online Remittance. Please find your username below:";
            mailBody += "<br><br>Username: " + username;
            mailBody += "<br>Password: " + pwd;
            mailBody +=
                "<br><br>Your login with "+ GetStatic.ReadWebConfig("jmeName", "") + "Remit is checked and was Rejected. Please fill the correct information";
            
            mailBody +=
               "<br><br>Thank You.";
            mailBody +=
               "<br><br><br>Regards,";
            mailBody +=
               "<br>"+ GetStatic.ReadWebConfig("jmeName", "") + " Online Team";
            mailBody +=
               "<br>Head Office";
            mailBody +=
               "<br>Post Code: 169-0073 Omori Building 4F(AB), Hyakunincho 1-10-7, Shinjuku-ku, Tokyo, Japan ";
            mailBody +=
               "<br>Phone number 08034104278 ";
            return mailBody;
        }
        protected void btnAudit_Click(object sender, EventArgs e)
        {
            var dbResult = _cd.AuditDocument(id, GetStatic.GetUser());
            GetStatic.AlertMessage(this, dbResult.Msg);
        }
    }
}