using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
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
                var response = KJBankAPIConnection.GetAccountDetailKJBank(newAccountNumber.Text, newBank.SelectedValue);
                if (response.ErrorCode == "0")
                {
                    hiddenDivCheck.Visible = true;
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

                var obj = new PartnerServiceModificationRequest()
                {
                    processDivision = "02",
                    institution = dr["bankCode"].ToString(),
                    depositor = dr["CustomerBankName"].ToString(),
                    no = dr["bankAccountNo"].ToString(),
                    virtualAccountNo = dr["walletAccountNo"].ToString(),
                    obpId = dr["obpId"].ToString()
                };

                obj.depositor = acNameInBank.Text;

                _dbRes = SendNotificationToKjBank(obj);

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
                        string fileName = customerId + "_" + GetTimestamp(DateTime.Now) + prefixNum.ToString() + extension;
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

        private DbResult SendNotificationToKjBank(PartnerServiceModificationRequest obj)
        {
            string body = new JavaScriptSerializer().Serialize((obj));
            var resp = KJBankAPIConnection.PostToKJBank(body);

            return resp;
        }
    }
}