using Newtonsoft.Json;
using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerControls
{
    public partial class ModifyBank : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private const string ViewFunctionIdAdmin = "20111700";
        private const string ViewFunctionIdAgent = "40120200";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDDL();
                acNameInBank.Attributes.Add("readonly", "readonly");
            }
        }

        private void Authenticate()
        {
            if (GetStatic.GetUserType() == "HO")
            {
                _sdd.CheckAuthentication(ViewFunctionIdAdmin);
            }
            else
            {
                _sdd.CheckAuthentication(ViewFunctionIdAgent);
            }
        }

        protected void PopulateDDL()
        {
            _sdd.SetDDL(ref newBank, "EXEC proc_customerBankModify @flag='DDL'", "bankCode", "BankName", "", "Select..");
        }

        protected void searchButton_Click(object sender, EventArgs e)
        {
            DataRow _dr = null;
            if (!string.IsNullOrEmpty(searchValue.Text))
            {
                _dr = _cd.GetCustomerDetailForBankUpdate(searchBy.SelectedValue, GetStatic.GetUser(), searchValue.Text);
            }
            if (_dr != null)
            {
                if (_dr["errorCode"].ToString() == "0")
                {
                    hideDivSearch.Visible = true;
                    hiddenDivCheck.Visible = false;

                    hddCustomerId.Value = _dr["customerId"].ToString();
                    fullName.Text = _dr["fullName"].ToString();
                    oldAccNumber.Text = _dr["bankAccountNo"].ToString();
                    alienNationId.Text = _dr["idNumber"].ToString();
                    oldBank.Text = _dr["BankName"].ToString();

                    hddHomePhone.Value = _dr["homePhone"].ToString();
                    hddImageName.Value = _dr["verifyDoc3"].ToString();
                    if (_dr["verifyDoc3"].ToString() != "")
                        verfDoc3.ImageUrl = "/AgentPanel/OnlineAgent/CustomerSetup/GetDocumentView.ashx?imageName=" + _dr["verifyDoc3"] + "&idNumber=" + _dr["homePhone"];

                    /*
                     * @Max-2018.09
                     * */
                    hddBankCode.Value = _dr["bankCode"].ToString();
                    hddIdType.Value = _dr["idType"].ToString();
                    hddDob.Value = _dr["dob"].ToString();
                    hddCountryCode.Value = _dr["nativeCountryCode"].ToString();
                    hddGender.Value = _dr["genderCode"].ToString();
                }
                else
                {
                    hiddenDivCheck.Visible = false;
                    hideDivSearch.Visible = false;
                    GetStatic.AlertMessage(this, _dr["msg"].ToString());
                }
            }
            else
            {
                hiddenDivCheck.Visible = false;
                hideDivSearch.Visible = false;
                GetStatic.AlertMessage(this, "No data Found!");
            }
        }

        protected void checkBtn_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(newAccountNumber.Text) && !string.IsNullOrEmpty(newBank.SelectedValue))
            {
                /*
                 * @Max-2018.09
                 * 실지명의 조회
                 * */
                //var response = KJBankAPIConnection.GetAccountDetailKJBank(newAccountNumber.Text, newBank.SelectedValue);

                var requestObj = new RealNameRequest()
                {
                    institution = newBank.SelectedValue,
                    no = newAccountNumber.Text
                };

                var idNumber = alienNationId.Text.Replace("-", "");

                //주민번호
                if (hddIdType.Value == "8008")
                {
                    requestObj.realNameDivision = "01";
                    requestObj.realNameNo = idNumber;
                }
                //외국인등록번호
                else if (hddIdType.Value == "1302")
                {
                    requestObj.realNameDivision = "02";
                    requestObj.realNameNo = idNumber;
                }
                //여권번호는 조합주민번호로 변경
                else if (hddIdType.Value == "10997")
                {
                    requestObj.realNameDivision = "04";

                    //조합주민번호(생년월일-성별-국적-여권번호(마지막5자리))
                    requestObj.realNameNo = String.Format("{0}{1}{2}{3}",
                                                        hddDob.Value,
                                                        hddGender.Value,
                                                        hddCountryCode.Value,
                                                        idNumber.Substring(idNumber.Length - 5));
                }
                string requestBody = JsonConvert.SerializeObject(requestObj);
                var response = KJBankAPIConnection.GetRealNameCheck(requestBody);
                if (response.ErrorCode == "0")
                {
                    hiddenDivCheck.Visible = true;
                    response.Msg = response.Msg.Split(':')[1];
                    response.Msg = response.Msg.Replace("}", "");
                    response.Msg = response.Msg.Trim();
                    acNameInBank.Text = response.Msg;
                }
                else
                {
                    hiddenDivCheck.Visible = false;
                    GetStatic.AlertMessage(this, "Bank Account Number is wrong, you can not modify the bank details!");
                }
            }
            else
            {
                GetStatic.AlertMessage(this, "Please input all data first!");
            }
        }

        protected void Modify_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(hddCustomerId.Value) || !string.IsNullOrWhiteSpace(acNameInBank.Text))
            {
                string verDoc4 = UploadDocument(VerificationDoc3, hddHomePhone.Value, 4000);
                if (verDoc4 == "invalidSize")
                {
                    GetStatic.AlertMessage(this, "File size exceeded for Passbook. Please upload image of size less than 2mb.");
                    return;
                }

                DbResult _dbRes = new DbResult();
                _dbRes = _cd.UpdateCustomerBankDetail(GetStatic.GetUser(), hddCustomerId.Value, newBank.SelectedValue, newAccountNumber.Text, acNameInBank.Text, verDoc4);

                if (_dbRes.ErrorCode != "0")
                {
                    hiddenDivCheck.Visible = false;
                    hideDivSearch.Visible = false;
                    searchValue.Text = "";

                    GetStatic.AlertMessage(this, _dbRes.Msg);
                    return;
                }

                //push to kj bank
                var dr = _cd.GetCustomerForModification(GetStatic.GetUser(), hddCustomerId.Value);

                /*
                 * @Max-2018.09
                 * 파트너서비스 정보등록
                 * */
                var requestObj = new PartnerServiceAccountRequest()
                {
                    processDivision = "02",
                    institution = dr["bankCode"].ToString(),
                    depositor = dr["CustomerBankName"].ToString(),
                    no = dr["bankAccountNo"].ToString(),
                    virtualAccountNo = dr["walletAccountNo"].ToString(),
                    obpId = dr["obpId"].ToString()
                };

                /*
                 * @Max 추가
                 * */
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

                requestObj.depositor = acNameInBank.Text;

                _dbRes = SendNotificationToKjBank(requestObj);

                if (!string.IsNullOrWhiteSpace(_dbRes.Id))
                {
                    ManageSaved();
                    GetStatic.AlertMessage(Page, "Customer Detail updated");
                }
                else
                {
                    GetStatic.AlertMessage(Page, "Customer detail not pushed to KJ Bank, please contact HO!");
                }
            }
            else
            {
                GetStatic.AlertMessage(Page, "Invalid account details, you can not modify this customer!");

                hiddenDivCheck.Visible = false;
                hideDivSearch.Visible = false;
                searchValue.Text = "";
            }
        }

        private void ManageSaved()
        {
            searchBy.SelectedValue = "idNumber";
            searchValue.Text = "";
            fullName.Text = "";
            alienNationId.Text = "";
            oldBank.Text = "";
            oldAccNumber.Text = "";
            newBank.SelectedValue = "";
            newAccountNumber.Text = "";
            acNameInBank.Text = "";
            verfDoc3.ImageUrl = "";

            hiddenDivCheck.Visible = false;
            hideDivSearch.Visible = false;
        }

        private string UploadDocument(FileUpload doc, string customerId, int prefixNum)
        {
            var maxFileSize = GetStatic.ReadWebConfig("csvFileSize", "2097152");
            string fName = "";
            try
            {
                var fileType = doc.PostedFile.ContentType;
                if (fileType == "image/jpeg" || fileType == "image/png" || fileType == "application/pdf")
                {
                    if (doc.PostedFile.ContentLength > Convert.ToDouble(maxFileSize))
                    {
                        fName = "invalidSize";
                    }
                    else
                    {
                        string extension = Path.GetExtension(doc.PostedFile.FileName);
                        string fileName = customerId + "_" + prefixNum.ToString() + extension;
                        string path = GetStatic.GetAppRoot() + "CustomerDocument\\" + customerId;
                        if (!Directory.Exists(path))
                            Directory.CreateDirectory(path);

                        doc.SaveAs(path + "/" + fileName);
                        fName = fileName;
                    }
                }
                else
                {
                    fName = "";
                }
            }
            catch (Exception ex)
            {
                fName = "";
            }
            return fName;
        }

        public static string GetTimestamp(DateTime value)
        {
            var timeValue = value.ToString("hhmmssffffff");
            return timeValue + DateTime.Now.Ticks;
        }

        /*
         * @Max-2018.09
         * 파트너서비스 정보등록
         * */

        private DbResult SendNotificationToKjBank(PartnerServiceAccountRequest obj)
        {
            string body = new JavaScriptSerializer().Serialize((obj));
            var resp = KJBankAPIConnection.CustomerRegistration(body);

            return resp;
        }
    }
}