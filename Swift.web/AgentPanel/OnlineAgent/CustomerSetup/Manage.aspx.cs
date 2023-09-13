using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;
using System.IO;
using System.Web.UI.WebControls;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private const string ViewFunctionId = "40120000";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
                string eId = GetStatic.ReadQueryString("id", "");
                if (eId != "")
                {
                    PopulateForm(eId);
                }
            }
        }

        private void PopulateForm(string eId)
        {
            var dr = _cd.GetCustomerDetails(eId, GetStatic.GetUser());
            if (null != dr)
            {
                hdnCustomerId.Value = dr["customerId"].ToString();
                firstName.Text = dr["firstName"].ToString();
                middleName.Text = dr["middleName"].ToString();
                lastName.Text = dr["lastName1"].ToString();
                genderList.SelectedValue = dr["gender"].ToString();
                countryList.Text = dr["country"].ToString();
                addressLine1.Text = dr["address"].ToString();
                postalCode.Text = dr["postalCode"].ToString();
                city.Text = dr["city"].ToString();
                email.Text = dr["email"].ToString();
                emailConfirm.Text = dr["email"].ToString();
                phoneNumber.Text = dr["telNo"].ToString();
                mobile.Text = dr["mobile"].ToString();
                nativeCountry.SelectedValue = dr["nativeCountry"].ToString();
                dob.Text = dr["dob"].ToString();
                occupation.Text = dr["occupation"].ToString();
                IssueDate.Text = dr["idIssueDate"].ToString();
                ExpireDate.Text = dr["idExpiryDate"].ToString();
                ddlBankName.SelectedValue = dr["bankName"].ToString();
                accountNumber.Text = dr["bankAccountNo"].ToString();

                idType.Text = dr["idType"].ToString();
                verificationTypeNo.Text = dr["idNumber"].ToString();
                hddIdNumber.Value = dr["homePhone"].ToString();

                //the value of homePhone is same as idNumber but for record id 1-92 homePhone is mobile number , bcoz of FolderName
                if (dr["verifyDoc1"].ToString() != "")
                    verfDoc1.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc1"] + "&idNumber=" + dr["homePhone"];
                if (dr["verifyDoc2"].ToString() != "")
                    verfDoc2.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc2"] + "&idNumber=" + dr["homePhone"];
                if (dr["verifyDoc3"].ToString() != "")
                    verfDoc3.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc3"] + "&idNumber=" + dr["homePhone"];
                if (dr["verifyDoc4"].ToString() != "")
                    verfDoc4.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc4"] + "&idNumber=" + dr["homePhone"];

                hdnVerifyDoc1.Value = dr["verifyDoc1"].ToString();
                hdnVerifyDoc2.Value = dr["verifyDoc2"].ToString();
                hdnVerifyDoc3.Value = dr["verifyDoc3"].ToString();
                hdnVerifyDoc4.Value = dr["verifyDoc4"].ToString();

                if (dr["idType"].ToString() == "8008")
                {
                    expiryDiv.Attributes.Add("style", "display:none;");
                    //expiryDiv.Visible = false;
                }
                else
                {
                    expiryDiv.Attributes.Add("style", "display:block;");
                    //expiryDiv.Visible = true;
                }

                //email.ReadOnly = true;
                //emailConfirm.ReadOnly = true;
                //mobile.ReadOnly = true;

                hddIsApproved.Value = dr["isApproved"].ToString();
                register.Enabled = (dr["isApproved"].ToString() == "Y") ? false : true;
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            _sl.SetDDL(ref genderList, "EXEC proc_online_dropDownList @flag='GenderList'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref countryList, "EXEC proc_online_dropDownList @flag='onlineCountrylist'", "countryId", "countryName", "", "Select..");
            _sl.SetDDL(ref nativeCountry, "EXEC proc_online_dropDownList @flag='allCountrylist'", "countryId", "countryName", "", "Select..");
            _sl.SetDDL(ref occupation, "EXEC proc_online_dropDownList @flag='occupationList'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref idType, "EXEC proc_online_dropDownList @flag='idType'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlBankName, "EXEC proc_dropDownList @flag='banklist'", "value", "text", "", "Select..");
        }

        protected void register_Click(object sender, EventArgs e)
        {
            if (hddIsApproved.Value == "Y")
            {
                GetStatic.AlertMessage(this, "You cannot modify approved customer!");
                return;
            }
            if (string.IsNullOrWhiteSpace(hddIdNumber.Value))
            {
                hddIdNumber.Value = verificationTypeNo.Text;
            }
            if (email.Text.Equals(emailConfirm.Text))
            {
                string verDoc1 = UploadDocument(VerificationDoc1, hddIdNumber.Value, 1000);
                if (verDoc1 == "invalidSize")
                {
                    GetStatic.AlertMessage(this, "File size exceeded for passport. Please upload image of size less than 2mb.");
                    return;
                }
                string verDoc2 = UploadDocument(VerificationDoc2, hddIdNumber.Value, 2000);
                if (verDoc2 == "invalidSize")
                {
                    GetStatic.AlertMessage(this, "File size exceeded for visa. Please upload image of size less than 2mb.");
                    return;
                }
                string verDoc3 = UploadDocument(VerificationDoc3, hddIdNumber.Value, 3000);
                if (verDoc3 == "invalidSize")
                {
                    GetStatic.AlertMessage(this, "File size exceeded for passport. Please upload image of size less than 2mb.");
                    return;
                }
                string verDoc4 = UploadDocument(VerificationDoc4, hddIdNumber.Value, 4000);
                if (verDoc4 == "invalidSize")
                {
                    GetStatic.AlertMessage(this, "File size exceeded for passport. Please upload image of size less than 2mb.");
                    return;
                }
                OnlineCustomerModel customerModel = new OnlineCustomerModel()
                {
                    flag = "customer-register-core"
                    ,
                    firstName = firstName.Text
                    ,
                    middleName = middleName.Text
                    ,
                    lastName1 = lastName.Text
                    ,
                    gender = genderList.SelectedValue
                    ,
                    country = countryList.Text
                    ,
                    address = addressLine1.Text
                    ,
                    zipCode = postalCode.Text
                    ,
                    city = city.Text
                    ,
                    email = email.Text
                    ,
                    homePhone = phoneNumber.Text
                    ,
                    mobile = mobile.Text
                    ,
                    nativeCountry = nativeCountry.SelectedValue
                    ,
                    dob = dob.Text
                    ,
                    occupation = occupation.Text
                    ,
                    postalCode = postalCode.Text
                    ,
                    idIssueDate = IssueDate.Text
                    ,
                    idExpiryDate = ExpireDate.Text
                    ,
                    idType = idType.Text
                    ,
                    idNumber = verificationTypeNo.Text
                    ,
                    telNo = phoneNumber.Text
                    ,
                    ipAddress = GetStatic.GetIp()
                    ,
                    createdBy = GetStatic.GetUser()
                    ,
                    verifyDoc1 = verDoc1
                    ,
                    verifyDoc2 = verDoc2
                    ,
                    verifyDoc3 = verDoc3
                    ,
                    verifyDoc4 = verDoc4
                    ,
                    bankId = ddlBankName.SelectedValue
                    ,
                    accountNumber = accountNumber.Text
                    ,
                    HasDeclare = (chkConfirm.Checked ? 1 : 0)
                };

                if (hdnCustomerId.Value != "")
                {
                    customerModel.customerId = hdnCustomerId.Value;
                    customerModel.flag = "customer-update-core";
                    if (verDoc1 == "")
                        customerModel.verifyDoc1 = hdnVerifyDoc1.Value;
                    if (verDoc2 == "")
                        customerModel.verifyDoc2 = hdnVerifyDoc2.Value;
                    if (verDoc3 == "")
                        customerModel.verifyDoc3 = hdnVerifyDoc3.Value;
                    if (verDoc4 == "")
                        customerModel.verifyDoc4 = hdnVerifyDoc4.Value;
                }

                var dbResult = _cd.RegisterCustomer(customerModel);
                if (dbResult.ErrorCode == "0")
                {
                    //if (hdnCustomerId.Value != "")
                    //{
                    //    if (!hddIdNumber.Value.Equals(verificationTypeNo.Text))
                    //    {
                    //        if (string.IsNullOrEmpty(verDoc1))
                    //        {
                    //            MoveFilesToNewFolder(hddIdNumber.Value, verificationTypeNo.Text, hdnVerifyDoc1.Value);
                    //        }
                    //        if (string.IsNullOrEmpty(verDoc2))
                    //        {
                    //            MoveFilesToNewFolder(hddIdNumber.Value, verificationTypeNo.Text, hdnVerifyDoc2.Value);
                    //        }
                    //        if (string.IsNullOrEmpty(verDoc3))
                    //        {
                    //            MoveFilesToNewFolder(hddIdNumber.Value, verificationTypeNo.Text, hdnVerifyDoc3.Value);
                    //        }
                    //        if (string.IsNullOrEmpty(verDoc4))
                    //        {
                    //            MoveFilesToNewFolder(hddIdNumber.Value, verificationTypeNo.Text, hdnVerifyDoc4.Value);
                    //        }

                    //        DeleteOldFolder(hddIdNumber.Value);
                    //    }
                    //}

                    GetStatic.SetMessage(dbResult);
                    Response.Redirect("List.aspx");
                    return;
                }
                else
                {
                    GetStatic.AlertMessage(this, dbResult.Msg);
                    return;
                }
            }
        }

        private void DeleteOldFolder(string folderName)
        {
            string dirPath = GetStatic.GetAppRoot() + "CustomerDocument\\" + folderName;

            if (Directory.Exists(dirPath))
                Directory.Delete(dirPath, true);
        }

        protected void MoveFilesToNewFolder(string oldFolderName, string newFolderName, string oldFileName)
        {
            string newFilePath = GetStatic.GetAppRoot() + "CustomerDocument\\" + newFolderName;

            if (!Directory.Exists(newFilePath))
                Directory.CreateDirectory(newFilePath);

            string oldFilePath = GetStatic.GetAppRoot() + "CustomerDocument\\" + oldFolderName + "\\" + oldFileName;
            FileInfo fileInfo = new FileInfo(oldFilePath);

            if (fileInfo.Exists)
                File.Move(oldFilePath, newFilePath + "/" + oldFileName);
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
    }
}