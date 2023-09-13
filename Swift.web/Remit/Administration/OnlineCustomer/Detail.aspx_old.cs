using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.OnlineCustomer
{
    public partial class Detail : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private string GMEWalletApiBaseUrl = GetStatic.ReadWebConfig("KJURL", "");
        private string secretKey = GetStatic.ReadWebConfig("KJsecretKey", "");
        private const string ContentType = "application/json";
        private const string ViewFunctionId = "20130000";
        private const string PartnerServiceKey = "1234";
        string m = GetStatic.ReadQueryString("m", "");
        string id = GetStatic.ReadQueryString("customerId", "");
        protected void Page_Load(object sender, EventArgs e)
        {
            //SendEmail("Test", "this is test<br><br><br>We look forward to provide you excellent service.", "pralhads.gmeremit.com");
            //KJBankAPIConnection.GetAccountDetailKJBank("28930104069405", "004");
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
            approve.Visible = false;
            var dr = _cd.GetVerifyCustomerDetails(id, GetStatic.GetUser());
            hdnCustomerId.Value = dr["customerId"].ToString();
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
            hdnAccountNumber.Value = accountNumber.Text;
            hdnVirtualAccountNo.Value = dr["walletAccountNo"].ToString();
            walletNumber.InnerText = dr["walletAccountNo"].ToString();

            var response = KJBankAPIConnection.GetAccountDetailKJBank(accountNumber.Text, dr["bankCode"].ToString());
            if (response.ErrorCode == "0")
            {
                lblBankAcName.Text = response.Msg;
                if (!string.IsNullOrWhiteSpace(lblBankAcName.Text))
                {
                    approve.Visible = true;
                }
            }
            else
            {
                GetStatic.AlertMessage(this, "Account Name in Bank is required");
            }

            if (dr["verifyDoc1"].ToString() != "")
                verfDoc1.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc1"] + "&mobileNo=" + dr["homePhone"];
            if (dr["verifyDoc2"].ToString() != "")
                verfDoc2.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc2"] + "&mobileNo=" + dr["homePhone"];
            if (dr["verifyDoc3"].ToString() != "")
                verfDoc3.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc3"] + "&mobileNo=" + dr["homePhone"];
            if (dr["verifyDoc4"].ToString() != "")
                verfDoc4.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc4"] + "&mobileNo=" + dr["homePhone"];


            if (!string.IsNullOrWhiteSpace(dr["obpId"].ToString()))
            {
                approve.Visible = false;
                btnAudit.Visible = (!string.IsNullOrWhiteSpace(dr["AuditDate"].ToString()) ? false : true);
                return;
            }
            
            if (dr["CustomerStatus"].ToString().ToLower() == "s")
            {
                divMsg.Visible = true;
                divMsg.InnerHtml = dr["SuspCust"].ToString();
            }

            
        }

        protected void approve_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(lblBankAcName.Text))
            {
                approve.Visible = false;
                GetStatic.AlertMessage(this, "Account Name in Bank is required");
                return;
            }   
            if (m == "ap")
            {
                var dbResult = _cd.ApprovePending(id, GetStatic.GetUser(), lblBankAcName.Text);
                if (dbResult.Tables.Count == 1)
                {
                    if (dbResult.Tables[0].Rows[0]["ErrorCode"].ToString() == "1")
                    {
                        msg.InnerText = dbResult.Tables[0].Rows[0]["Msg"].ToString();
                        msg.Visible = true;
                    }
                }
                else if (dbResult.Tables.Count == 2)
                {
                    msg.Visible = false;
                    if (dbResult.Tables[1].Rows[0]["ErrorCode"].Equals("0"))
                    {
                        if (dbResult.Tables[0].Rows[0]["username"] != null)
                        {
                            string channel = dbResult.Tables[0].Rows[0]["channel"].ToString();
                            string username = dbResult.Tables[0].Rows[0]["username"].ToString();
                            string pwd = dbResult.Tables[0].Rows[0]["password"].ToString();
                            string walletAccountNo = dbResult.Tables[0].Rows[0]["walletAccountNo"].ToString();
                            string bankAccountNo = dbResult.Tables[0].Rows[0]["bankAccountNo"].ToString();
                            string fullName = dbResult.Tables[0].Rows[0]["fullName"].ToString();
                            string CustomerBankName = dbResult.Tables[0].Rows[0]["CustomerBankName"].ToString();
                            if (string.IsNullOrWhiteSpace(CustomerBankName))
                            {
                                approve.Visible = false;
                                GetStatic.AlertMessage(this, "Account Name in Bank is required");
                                return;
                            }
                            string msgBody = GetApprovedCustomerMsgBody(channel, username, pwd, walletAccountNo);
                            string msgSubject = "Customer verification approved";

                            var response =  SendNotificationToKjBank(CustomerBankName, bankAccountNo, walletAccountNo, dbResult.Tables[0].Rows[0]["bankCode"].ToString());
                            if (response.ErrorCode == "0")
                            {
                                Task.Factory.StartNew(() => { SendEmail(msgSubject, msgBody, username); });
                            }
                        }
                        GetStatic.SetMessage(dbResult.Tables[1].Rows[0]["ErrorCode"].ToString(), dbResult.Tables[1].Rows[0]["Msg"].ToString());

                        //var url = "~/GMEAPI/GMERegistrationForDepositVerification.aspx?processDivision=" + ProcessDivision + "&institution=" + hdninstitution.Value + "&AccountName=" + hdnAccountName.Value + "&AccountNumber=" + hdnAccountNumber.Value + "&VirtualAccountNo=" + hdnVirtualAccountNo.Value + "&partnerServiceKey=" + PartnerServiceKey + "&id=" + id;
                        //Response.Redirect(url);
                        Response.Redirect("ApprovedList.aspx");
                    }
                }

                GetStatic.AlertMessage(Page, dbResult.Tables[0].Rows[0]["msg"].ToString());
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

        private DbResult SendNotificationToKjBank(string AccountName, string AccountNumber, string VirtualAccountNo, string bankCode)
        {
            var reqObject = new PartnerServiceAccountRequest();
            reqObject.processDivision = "01";
            reqObject.institution = bankCode;
            reqObject.depositor = AccountName;
            reqObject.no = AccountNumber;
            reqObject.virtualAccountNo = VirtualAccountNo;
           
            string body = new JavaScriptSerializer().Serialize((reqObject));

            var response = KJBankAPIConnection.PostToKJBank(body);

            if (response.ErrorCode == "0")
            {
                var dbresult = _cd.UpdateObpId(id, GetStatic.GetUser(), response.Id);
                response = dbresult;
                if (dbresult.ErrorCode == "0")
                {
                    GetStatic.CallBackJs1(Page, "Show Alert", "ShowAlert('Virtual Account registration successfully');");
                }
            }
            else
            {
                GetStatic.CallBackJs1(Page, "Show Alert", "ShowAlert('Fail to register customer through API');");
            }
            return response;
        }

        private void SendEmail(string msgSubject, string msgBody, string toEmailId)
        {
            SmtpMailSetting mail = new SmtpMailSetting
            {
                MsgBody = msgBody,
                MsgSubject = msgSubject,
                ToEmails = toEmailId
            };

            mail.SendSmtpMail(mail, GetStatic.GetAppRoot()+"/SampleFile/GME-TermsAndConditions.pdf");
            
        }

        public string GetApprovedCustomerMsgBody(string channel, string username, string pwd, string account)
        {
            var mailBody = "Dear Mr./Ms./Mrs. " + fullName.Text + ",";
            if (channel == "online")
            {

                mailBody +=
                    "<br><br>Thank you for registering with GME Online Remittance.";
            }
            else
            {
                mailBody +=
                    "<br><br>Thank you for registering with GME Online Remittance. Please find your username below:";
                mailBody += "<br><br>Username: " + username;
                mailBody += "<br>Password: " + pwd;

            }
            mailBody +=
                "<br><br>Your login with GMERemit is checked and validated. You can now start sending remittance to your desired country.";
            mailBody +=
                "<br><br><br>PROCESS TO TRANSFER FUNDS:";
            mailBody += "<br>• Your unique account number with GME is " + account + ", it is displayed in your login window all the time";
            mailBody += "<br>• Please make your desired transfer in your GME account through your nearest ATM or ebanking";
            mailBody += "<br>• Login to <a href=\"http://www.gmeremit.com\"> www.gmeremit.com </a> and click send money. Please enter your beneficiary details to transfer funds";
            mailBody += "<br>• For cash transfers, you will receive a PIN Code after successfully submitting your details. For account transfers to your desired country, GME will process the transactions to be deposited within 24 hours (deposit time may vary where beneficiary banks are not easily accessible)";
            mailBody += "<br>• All cash transfers has to be verified by GME and are ready to collect at your location within an hour";

            mailBody += "<br><br>Note: *All Receipts generated after successful transfers are also sent to your registered email.";
            mailBody += "<br><br><br>*Money transfer limit per transaction is USD 3,000 and USD 20,000 for 1 year.";
            mailBody +=
                "<br><br>If you need further assistance kindly reply this email or call us at <br/>";
            mailBody += @"Tel. 1588 6864 (Multi-language Support) <br/>
                            010 2959 6864 (Nepal) <br/>
                            010 2930 6864 (Vietnam)<br/>
                            010 2971 6864 (Cambodia)<br/>
                            010 2970 6864 (Philippines)<br/>
                            010 2837 6864 (Sri lanka)<br/>
                            010 2760 6864 (Pakistan/India)<br/>
                            010 2967 6864 (Bangladesh)<br/>
                            010 3015 6864 (Uzbekistan)<br/>";

            mailBody += "or visit our website <a href=\"http://www.gmeremit.com\"> www.gmeremit.com </a>";

            mailBody +=
                "<br><br><br>We look forward to provide you excellent service.";
            mailBody +=
               "<br><br>Thank You.";
            mailBody +=
               "<br><br><br>Regards,";
            mailBody +=
               "<br>GME Online Team";
            mailBody +=
               "<br>Head Office";
            mailBody +=
               "<br>325, Jong-ro, ";
            mailBody +=
               "<br>Jongno-gu, 03104 Seoul, Korea ";
            mailBody +=
               "<br>Phone number 1588 6864 ";
            return mailBody;
        }

        protected void btnAudit_Click(object sender, EventArgs e)
        {
            var dbResult = _cd.AuditDocument(id, GetStatic.GetUser());
            GetStatic.AlertMessage(this,dbResult.Msg);
        }

    }
}