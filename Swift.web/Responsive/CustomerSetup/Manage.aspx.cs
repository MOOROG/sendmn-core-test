using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;
using System.IO;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Responsive.customerSetup
{
    public partial class Manage : Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private const string ViewFunctionId = "20111300";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            showOnEdit.Visible = false;
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
                string eId = GetStatic.ReadQueryString("customerId", "");
                if (eId != "")
                {
                    PopulateForm(eId);
                    DisableFields();
                }
            }
        }

        private void DisableFields()
        {
            idType.Attributes.Add("readonly", "readonly");
            //verificationTypeNo.Attributes.Add("readonly", "readonly");
            //ExpireDate.Attributes.Add("readonly", "readonly");
            ddlBankName.Attributes.Add("readonly", "readonly");
            //accountNumber.Attributes.Add("readonly", "readonly");
            VerificationDoc1.Attributes.Add("readonly", "readonly");
            VerificationDoc2.Attributes.Add("readonly", "readonly");
            VerificationDoc3.Attributes.Add("readonly", "readonly");
            VerificationDoc4.Attributes.Add("readonly", "readonly");
        }

        private void PopulateForm(string eId)
        {
            var dr = _cd.GetCustomerDetails(eId, GetStatic.GetUser());
            if (null != dr)
            {
                showOnEdit.Visible = true;
                hdnCustomerId.Value = dr["customerId"].ToString();
                firstName.Text = dr["firstName"].ToString();
                middleName.Text = dr["middleName"].ToString();
                lastName.Text = dr["lastName1"].ToString();
                txtCompanyName.Text = dr["firstName"].ToString();
                genderList.SelectedValue = dr["gender"].ToString();
                countryList.SelectedValue = dr["country"].ToString();
                addressLine1.Text = dr["address"].ToString();
                zipCode.Text = dr["zipCode"].ToString();
                city.Text = dr["city"].ToString();
                email.Text = dr["email"].ToString();
                hddOldEmailValue.Value = dr["email"].ToString();
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
                idType.SelectedValue = dr["idType"].ToString();
                verificationTypeNo.Text = dr["idNumber"].ToString();
                hddIdNumber.Value = dr["homePhone"].ToString();
                txtMembershipId.Text = dr["membershipId"].ToString();
                hdnMembershipNo.Value = dr["membershipId"].ToString();
                txtMembershipId.Attributes.Add("readonly", "readonly");
                txtRegistrationNo.Text = dr["registerationNo"].ToString();
                txtDateOfIncorporation.Text = dr["dateofIncorporation"].ToString();
                txtNameofAuthoPerson.Text = dr["nameOfAuthorizedPerson"].ToString();
                txtStreet.Text = dr["street"].ToString();
                txtsenderCityjapan.Text = dr["cityUnicode"].ToString();
                txtstreetJapanese.Text = dr["streetUnicode"].ToString();
                txtNameofEmployeer.Text = dr["nameOfEmployeer"].ToString();
                rbRemitanceAllowed.SelectedValue = (dr["remittanceAllowed"].ToString() == "Y" ? "Enabled" : "Disabled");
                rbOnlineLogin.SelectedValue = (dr["onlineUser"].ToString() == "Y" ? "Enabled" : "Disabled");
                txtRemarks.Text = dr["remarks"].ToString();
                txtSSnNo.Text = dr["SSNNO"].ToString();

                ddlCustomerType.SelectedValue = dr["customerType"].ToString();
                ddlnatureOfCompany.SelectedValue = dr["natureOfCompany"].ToString();
                ddlPosition.SelectedValue = dr["position"].ToString();
                ddlVisaStatus.SelectedValue = dr["visaStatus"].ToString();
                ddlEmployeeBusType.SelectedValue = dr["employeeBusinessType"].ToString();
                ddSourceOfFound.SelectedValue = dr["sourceOfFund"].ToString();
                ddlOrganizationType.SelectedValue = dr["organizationType"].ToString();
                setStateDll(countryList.SelectedValue, zipCode.Text, dr["state"].ToString());
                //the value of homePhone is same as idNumber but for record id 1-92 homePhone is mobile number , bcoz of FolderName
                if (dr["verifyDoc1"].ToString() != "")
                    verfDoc1.ImageUrl = "../../../AgentPanel/OnlineAgent/CustomerSetup/GetDocumentView.ashx?imageName=" + dr["verifyDoc1"] + "&idNumber=" + dr["membershipId"];
                if (dr["verifyDoc2"].ToString() != "")
                    verfDoc2.ImageUrl = "../../../AgentPanel/OnlineAgent/CustomerSetup/GetDocumentView.ashx?imageName=" + dr["verifyDoc2"] + "&idNumber=" + dr["membershipId"];
                if (dr["verifyDoc3"].ToString() != "")
                    verfDoc3.ImageUrl = "../../../AgentPanel/OnlineAgent/CustomerSetup/GetDocumentView.ashx?imageName=" + dr["verifyDoc3"] + "&idNumber=" + dr["membershipId"];
                if (dr["verifyDoc4"].ToString() != "")
                    verfDoc4.ImageUrl = "../../../AgentPanel/OnlineAgent/CustomerSetup/GetDocumentView.ashx?imageName=" + dr["verifyDoc4"] + "&idNumber=" + dr["membershipId"];

                hdnVerifyDoc1.Value = dr["verifyDoc1"].ToString();
                hdnVerifyDoc2.Value = dr["verifyDoc2"].ToString();
                hdnVerifyDoc3.Value = dr["verifyDoc3"].ToString();
                hdnVerifyDoc4.Value = dr["verifyDoc4"].ToString();

                email.Enabled = (dr["isTxnMade"].ToString() == "Y") ? false : true;
                emailConfirm.Enabled = (dr["isTxnMade"].ToString() == "Y") ? false : true;
                hddTxnsMade.Value = dr["isTxnMade"].ToString();
                if (dr["isTxnMade"].ToString() == "Y")
                {
                    msgDiv.Visible = true;
                    msgLabel.Text = "Note: The customer has already made transactions in JME system, so the email can not be modified. For more info please contact HO.";
                }

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
                membershipDiv.Visible = true;
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDdl()
        {
            _sl.SetDDL(ref genderList, "EXEC proc_online_dropDownList @flag='GenderList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref countryList, "EXEC proc_online_dropDownList @flag='onlineCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "");
            _sl.SetDDL(ref nativeCountry, "EXEC proc_online_dropDownList @flag='allCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "Select..");
            _sl.SetDDL(ref occupation, "EXEC proc_online_dropDownList @flag='occupationList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref idType, "EXEC proc_online_dropDownList @flag='idType',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlBankName, "EXEC proc_online_sendPageLoadData @flag='banklist'", "value", "text", "", "Select..");
            _sl.SetDDL(ref ddlCustomerType, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=4700", "valueId", "detailTitle", ddlCustomerType.SelectedValue, "");
            _sl.SetDDL(ref ddlOrganizationType, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7002", "valueId", "detailTitle", "", "");
            _sl.SetDDL(ref ddlnatureOfCompany, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7003", "valueId", "detailTitle", "", "");
            _sl.SetDDL(ref ddSourceOfFound, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3900", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlEmployeeBusType, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7004", "valueId", "detailTitle", "", "");
            _sl.SetDDL(ref ddlVisaStatus, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7005", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlPosition, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7006", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlState, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@countryId='" + null + "',@zipCode ='" + null + "'", "stateId", "stateName", "", "Select..");
        }

        protected void register_Click(object sender, EventArgs e)
        {
            if (hddTxnsMade.Value == "Y" && (!email.Text.Equals(hddOldEmailValue.Value.ToString())))
            {
                GetStatic.AlertMessage(this, "You can not change the email of customer who have already done transaction!");
                return;
            }

            //if (email.Text.Equals(emailConfirm.Text))
            //{

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
                gender = genderList.SelectedValue,
                customerType = ddlCustomerType.SelectedValue,
                country = countryList.Text
                ,
                address = addressLine1.Text
                ,
                zipCode = zipCode.Text
                ,
                street = txtStreet.Text,
                city = city.Text,
                state = ddlState.SelectedValue,
                senderCityjapan = txtsenderCityjapan.Text,
                email = email.Text
                ,
                streetJapanese = txtstreetJapanese.Text,
                homePhone = phoneNumber.Text
                ,
                mobile = mobile.Text
                ,
                visaStatus = ddlVisaStatus.SelectedValue,
                employeeBusinessType = ddlEmployeeBusType.SelectedValue,
                nativeCountry = nativeCountry.SelectedValue
                ,
                dob = dob.Text,
                ssnNo = txtSSnNo.Text,
                sourceOfFound = ddSourceOfFound.SelectedValue,
                occupation = occupation.Text
                ,
                telNo = phoneNumber.Text
                ,
                ipAddress = GetStatic.GetIp()
                ,
                createdBy = GetStatic.GetUser()
                ,

                bankId = ddlBankName.SelectedValue
                ,
                accountNumber = accountNumber.Text
                ,
                idNumber = verificationTypeNo.Text
                ,
                idIssueDate = IssueDate.Text
                ,
                idExpiryDate = ExpireDate.Text
                ,
                idType = idType.Text,
                membershipId = txtMembershipId.Text,
                remitanceAllowed = (rbRemitanceAllowed.SelectedValue == "Enabled" ? true : false),
                onlineUser = (rbOnlineLogin.SelectedValue == "Enabled" ? true : false),
                remarks = txtRemarks.Text,
                registrationNo = txtRegistrationNo.Text,
                natureOfCompany = ddlnatureOfCompany.Text,
                organizationType = ddlOrganizationType.SelectedValue,
                dateOfIncorporation = txtDateOfIncorporation.Text,
                position = ddlPosition.SelectedValue,
                nameofAuthoPerson = txtNameofAuthoPerson.Text,
                nameofEmployeer = txtNameofEmployeer.Text,
                companyName = txtCompanyName.Text
            };

            if (hdnCustomerId.Value != "")
            {
                customerModel.customerId = hdnCustomerId.Value;
                customerModel.flag = "customer-update-new";
            }

            var dbResult = _cd.RegisterCustomerNew(customerModel);
            if (dbResult.ErrorCode == "0")
            {
                GetStatic.SetMessage(dbResult);
                if (!string.IsNullOrWhiteSpace(hdnCustomerId.Value))
                {
                    Response.Redirect("List.aspx");
                }
                Response.Redirect("Manage.aspx?customerId=" + dbResult.Id);
                return;
            }
            else
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
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

        private string UploadDocument(FileUpload doc, string uploadType)
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
                        string fileExtension = new FileInfo(doc.FileName).Extension;
                        string fileName = hdnCustomerId.Value + "_" + GetTimestamp(DateTime.Now) + "_" + uploadType + fileExtension;
                        fileName = Regex.Replace(fileName, @"[;,/:\t\r ]|[\n]{2}", "_");
                        string path = GetStatic.GetFilePath() + "CustomerDocument\\" + hdnMembershipNo.Value;
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
            return value.Ticks.ToString();
        }

        protected void zipCode_TextChanged(object sender, EventArgs e)
        {
            var countryId = countryList.SelectedValue;
            if (countryId != "")
            {
                setStateDll(countryId, zipCode.Text, ddlState.SelectedValue);
            }
        }

        private void setStateDll(string countryId, string zipCode, string stateId)
        {
            if (countryId != "")
            {
                _sl.SetDDL(ref ddlState, "EXEC proc_online_dropDownList @flag='state',@countryId='" + countryList.SelectedValue + "',@zipCode ='" + zipCode + "'", "stateId", "stateName", stateId, "Select..");
            }
        }

        protected void btnFileUpload_Click(object sender, EventArgs e)
        {
            string verDoc1 = (!string.IsNullOrWhiteSpace(VerificationDoc1.FileName) ? UploadDocument(VerificationDoc1, "Reg_ID_Front") : hdnVerifyDoc1.Value);
            if (verDoc1 == "invalidSize")
            {
                GetStatic.AlertMessage(this, "File size exceeded for passport. Please upload image of size less than 2mb.");
                return;
            }
            string verDoc2 = (!string.IsNullOrWhiteSpace(VerificationDoc2.FileName) ? UploadDocument(VerificationDoc2, "Reg_ID_Back") : hdnVerifyDoc2.Value);
            if (verDoc2 == "invalidSize")
            {
                GetStatic.AlertMessage(this, "File size exceeded for visa. Please upload image of size less than 2mb.");
                return;
            }
            string verDoc3 = (!string.IsNullOrWhiteSpace(VerificationDoc3.FileName) ? UploadDocument(VerificationDoc3, "Reg_Passport_Front") : hdnVerifyDoc3.Value);
            if (verDoc3 == "invalidSize")
            {
                GetStatic.AlertMessage(this, "File size exceeded for passport. Please upload image of size less than 2mb.");
                return;
            }
            string verDoc4 = (!string.IsNullOrWhiteSpace(VerificationDoc4.FileName) ? UploadDocument(VerificationDoc4, "Reg_Passport_Back") : hdnVerifyDoc4.Value);
            if (verDoc4 == "invalidSize")
            {
                GetStatic.AlertMessage(this, "File size exceeded for passport. Please upload image of size less than 2mb.");
                return;
            }

            OnlineCustomerModel onlineCustomer = new OnlineCustomerModel()
            {
                customerId = hdnCustomerId.Value,
                flag = "fileUpload",
                verifyDoc1 = verDoc1,
                verifyDoc2 = verDoc2,
                verifyDoc3 = verDoc3,
                verifyDoc4 = verDoc4
            };
            var dbResult = _cd.AddAndUpdateCustomerDocument(onlineCustomer);
            if (dbResult.ErrorCode == "0")
            {
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
}