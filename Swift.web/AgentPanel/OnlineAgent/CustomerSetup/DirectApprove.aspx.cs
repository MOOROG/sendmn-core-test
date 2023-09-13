using Newtonsoft.Json;
using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerSetup
{
    public partial class DirectApprove : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private string GMEWalletApiBaseUrl = GetStatic.ReadWebConfig("KJURL", "");
        private string secretKey = GetStatic.ReadWebConfig("KJsecretKey", "");
        private const string ContentType = "application/json";
        private const string ViewFunctionId = "40120000";
        private const string PartnerServiceKey = "1234";
        private string m = GetStatic.ReadQueryString("m", "");
        private string id = GetStatic.ReadQueryString("customerId", "");

        protected void Page_Load(object sender, EventArgs e)
        {
            //SendEmail("Test", "this is test<br><br><br>We look forward to provide you excellent service.", "pralhad@swifttech.com.np");
            //return;
            //KJBankAPIConnection.GetAccountDetailKJBank("0001107000816", "034");
            _sl.CheckSession();
            btnApprove.Visible = false;
            if (!IsPostBack)
            {
                Authenticate();

                if (id != "")
                {
                    if (m != "")
                    {
                        btnApprove.Visible = true;
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
            btnApprove.Visible = false;
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

            /*
             * @Max- 2018.09
             * 광주은행 - 실지명의조회
             * */
            hdnIdTypeCode.Value = dr["idTypeCode"].ToString();
            hdnGenderCode.Value = dr["genderCode"].ToString();
            hdnNativeCountryCode.Value = dr["nativeCountryCode"].ToString();
            hdnDobYmd.Value = dr["dobYMD"].ToString();

            //var response = KJBankAPIConnection.GetAccountDetailKJBank(accountNumber.Text, dr["bankCode"].ToString());
            var request = new RealNameRequest();
            request.institution = dr["bankCode"].ToString();
            request.no = accountNumber.Text;

            var idNumber = verificationTypeNo.Text.Replace("-", "");

            //주민번호
            if (hdnIdTypeCode.Value == "8008")
            {
                request.realNameDivision = "01";
                request.realNameNo = idNumber;
            }
            //외국인등록번호
            else if (hdnIdTypeCode.Value == "1302")
            {
                request.realNameDivision = "02";
                request.realNameNo = idNumber;
            }
            //여권번호는 조합주민번호로 변경
            else if (hdnIdTypeCode.Value == "10997")
            {
                request.realNameDivision = "04";

                //조합주민번호(생년월일-성별-국적-여권번호(마지막5자리))
                request.realNameNo = String.Format("{0}{1}{2}{3}",
                                                    hdnDobYmd.Value,
                                                    hdnGenderCode.Value,
                                                    hdnNativeCountryCode.Value,
                                                    idNumber.Substring(idNumber.Length - 5));
            }

            string requestBody = JsonConvert.SerializeObject(request);
            var response = KJBankAPIConnection.GetRealNameCheck(requestBody);

            if (response.ErrorCode == "0")
            {
                response.Msg = response.Msg.Split(':')[1];
                response.Msg = response.Msg.Replace("}", "");
                response.Msg = response.Msg.Trim();
                lblBankAcName.Text = response.Msg;

                if (!string.IsNullOrWhiteSpace(lblBankAcName.Text))
                {
                    btnApprove.Visible = true;
                }
            }
            else
            {
                GetStatic.AlertMessage(this, "Account Name in Bank is required");
            }
            //AcBankName.Text = KJBankAPIConnection.GetAccountDetailKJBank(accountNumber.Text, dr["bankCode"].ToString()).Msg;
            //AcBankName.Text = AcBankName.Text.Replace("\"", "");

            if (dr["verifyDoc1"].ToString() != "")
                verfDoc1.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc1"] + "&idNumber=" + dr["homePhone"];
            if (dr["verifyDoc2"].ToString() != "")
                verfDoc2.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc2"] + "&idNumber=" + dr["homePhone"];
            if (dr["verifyDoc3"].ToString() != "")
                verfDoc3.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc3"] + "&idNumber=" + dr["homePhone"];
            if (dr["verifyDoc4"].ToString() != "")
                verifyDoc4.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc4"] + "&idNumber=" + dr["homePhone"];
        }

        protected void approve_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(lblBankAcName.Text))
            {
                btnApprove.Visible = false;
                GetStatic.AlertMessage(this, "Account Name in Bank is required");
                return;
            }
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
                            btnApprove.Visible = false;
                            GetStatic.AlertMessage(this, "Account Name in Bank is required");
                            return;
                        }
                        string msgBody = GetApprovedCustomerMsgBody(channel, username, pwd, walletAccountNo);
                        string msgSubject = "Customer verification approved";

                        /*
                         * @Max - 2018.09
                         * 광주은행-파트너서비스 등록
                         * */
                        var requestObj = new PartnerServiceAccountRequest()
                        {
                            processDivision = "01",
                            institution = dbResult.Tables[0].Rows[0]["bankCode"].ToString(),
                            depositor = CustomerBankName,
                            no = bankAccountNo,
                            virtualAccountNo = walletAccountNo,
                            obpId = ""
                        };
                        var idNumber = dbResult.Tables[0].Rows[0]["idNumber"].ToString().Replace("-", "");

                        //주민번호
                        if (dbResult.Tables[0].Rows[0]["idType"].ToString() == "8008")
                        {
                            requestObj.realNameDivision = "01";
                            requestObj.realNameNo = idNumber;
                        }
                        //외국인등록번호
                        else if (dbResult.Tables[0].Rows[0]["idType"].ToString() == "1302")
                        {
                            requestObj.realNameDivision = "02";
                            requestObj.realNameNo = idNumber;
                        }
                        //여권번호는 조합주민번호로 변경
                        else if (dbResult.Tables[0].Rows[0]["idType"].ToString() == "10997")
                        {
                            requestObj.realNameDivision = "04";

                            //조합주민번호(생년월일-성별-국적-여권번호(마지막5자리))
                            requestObj.realNameNo = String.Format("{0}{1}{2}{3}",
                                                        dbResult.Tables[0].Rows[0]["dobYMD"].ToString(),
                                                        dbResult.Tables[0].Rows[0]["genderCode"].ToString(),
                                                        dbResult.Tables[0].Rows[0]["nativeCountryCode"].ToString(),
                                                        idNumber.Substring(idNumber.Length - 5));
                        }

                        //var response = SendNotificationToKjBank(CustomerBankName, bankAccountNo, walletAccountNo, dbResult.Tables[0].Rows[0]["bankCode"].ToString());
                        var response = SendNotificationToKjBank(requestObj);
                        if (response.ErrorCode == "0")
                        {
                            Task.Factory.StartNew(() => { SendEmail(msgSubject, msgBody, username); });
                        }
                    }
                    GetStatic.SetMessage(dbResult.Tables[1].Rows[0]["ErrorCode"].ToString(), dbResult.Tables[1].Rows[0]["Msg"].ToString());

                    //var url = "~/GMEAPI/GMERegistrationForDepositVerification.aspx?processDivision=" + ProcessDivision + "&institution=" + hdninstitution.Value + "&AccountName=" + hdnAccountName.Value + "&AccountNumber=" + hdnAccountNumber.Value + "&VirtualAccountNo=" + hdnVirtualAccountNo.Value + "&partnerServiceKey=" + PartnerServiceKey + "&id=" + id;
                    //Response.Redirect(url);
                    Response.Redirect("List.aspx");
                }
            }

            GetStatic.AlertMessage(Page, dbResult.Tables[0].Rows[0]["msg"].ToString());
        }

        /*
         * @Max - 2018.09
         * KJBank - 파트너서비스 정보등록
         * */

        // private DbResult SendNotificationToKjBank(string AccountName, string AccountNumber, string
        // VirtualAccountNo, string bankCode)
        private DbResult SendNotificationToKjBank(PartnerServiceAccountRequest reqObject)
        {
            //var reqObject = new PartnerServiceAccountRequest();
            //reqObject.processDivision = "01";
            //reqObject.institution = bankCode;
            //reqObject.depositor = AccountName;
            //reqObject.no = AccountNumber;
            //reqObject.virtualAccountNo = VirtualAccountNo;

            string body = new JavaScriptSerializer().Serialize((reqObject));

            var response = KJBankAPIConnection.CustomerRegistration(body);
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

            mail.SendSmtpMail(mail, GetStatic.ReadWebConfig("defaultDocPath") + "/SampleFile/GME-TermsAndConditions.pdf");
        }

        public string GetApprovedCustomerMsgBody(string channel, string username, string pwd, string account)
        {
            var mailBody = "Dear Mr./Ms./Mrs. " + fullName.Text + ",";
            if (channel == "online")
            {
                mailBody +=
                    "<br><br>Thank you for registering with JME Online Remittance.";
            }
            else
            {
                mailBody +=
                    "<br><br>Thank you for registering with JME Online Remittance. Please find your username below:";
                mailBody += "<br><br>Username: " + username;
                mailBody += "<br>Password: " + pwd;
            }
            mailBody +=
                "<br><br>Your login with JMERemit is checked and validated. You can now start sending remittance to your desired country.";
            mailBody +=
                "<br><br><br>PROCESS TO TRANSFER FUNDS:";
            mailBody += "<br>• Your unique account number with JME is " + account + ", it is displayed in your login window all the time";
            mailBody += "<br>• Please make your desired transfer in your JME account through your nearest ATM or ebanking";
            mailBody += "<br>• Login to <a href=\"http://www.gmeremit.com\"> www.gmeremit.com </a> and click send money. Please enter your beneficiary details to transfer funds";
            mailBody += "<br>• For cash transfers, you will receive a PIN Code after successfully submitting your details. For account transfers to your desired country, JME will process the transactions to be deposited within 24 hours (deposit time may vary where beneficiary banks are not easily accessible)";
            mailBody += "<br>• All cash transfers has to be verified by JME and are ready to collect at your location within an hour";

            mailBody += "<br><br>Note: *All Receipts generated after successful transfers are also sent to your registered email.";
            mailBody += "<br><br><br>*Money transfer limit per transaction is USD 3,000 and USD 20,000 for 1 year.";
            mailBody +=
                "<br><br>If you need further assistance kindly reply this email or call us at 02-3673-5559. or visit our website <a href=\"http://www.gmeremit.com\"> www.gmeremit.com </a>";
            mailBody +=
                "<br><br><br>We look forward to provide you excellent service.";
            mailBody +=
               "<br><br>Thank You.";
            mailBody +=
               "<br><br><br>Regards,";
            mailBody +=
               "<br>JME Online Team";
            mailBody +=
               "<br>Head Office";
            mailBody +=
               "<br>325, Jong-ro, ";
            mailBody +=
               "<br>Jongno-gu, 03104 Seoul, Korea ";
            mailBody +=
               "<br>Phone number 02-3673-5559 ";
            return mailBody;
        }
    }
}