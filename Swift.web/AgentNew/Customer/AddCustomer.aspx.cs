using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using System.Web;

namespace Swift.web.AgentNew.Customer
{
    public partial class AddCustomer : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private const string ViewFunctionId = "20202000";
        private const string AddFunctionId = "20202010";
        private const string SignatureFunctionId = "20202020";

        protected void Page_Load(object sender, EventArgs e)
        {
            signatureDiv.Visible = _sl.HasRight(SignatureFunctionId);
            isDisplaySignature.Value = _sl.HasRight(SignatureFunctionId) ? "true" : "false";
            _sl.CheckSession();
            GetStatic.PrintMessage(this);
            var MethodName = Request.Form["MethodName"];
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl();
                if (MethodName == "GetAddressDetailsByZipCode")
                {
                    GetAddressDetailsByZipCode();
                }
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);

            string eId = GetStatic.ReadQueryString("customerId", "");

            var hasRight = false;
            hasRight = _sl.HasRight(AddFunctionId);

            register.Enabled = hasRight;
            register.Visible = hasRight;
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        private void PopulateDdl()
        {
            _sl.SetDDL(ref genderList, "EXEC proc_online_dropDownList @flag='GenderList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref countryList, "EXEC proc_online_dropDownList @flag='onlineCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "");
            _sl.SetDDL(ref nativeCountry, "EXEC proc_online_dropDownList @flag='allCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "Select..");
            _sl.SetDDL(ref occupation, "EXEC proc_online_dropDownList @flag='occupationList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref idType, "EXEC proc_online_dropDownList @flag='IdTypeWithDetails',@user='" + GetStatic.GetUser() + "',@countryId='" + countryList.SelectedValue + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlCustomerType, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=4700", "valueId", "detailTitle", ddlCustomerType.SelectedValue, "");
            _sl.SetDDL(ref ddlOrganizationType, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7002", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlnatureOfCompany, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7003", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddSourceOfFound, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3900", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlEmployeeBusType, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7004", "valueId", "detailTitle", "", "");
            _sl.SetDDL(ref ddlVisaStatus, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7005", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlPosition, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7006", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlState, "EXEC proc_online_dropDownList @flag='state',@countryId='" + countryList.SelectedValue + "'", "stateId", "stateName", "", "Select..");
        }

        private void GetAddressDetailsByZipCode()
        {
            string zipCode = Request.Form["zipCode"];
            if (!Regex.Match(zipCode, @"^\d{7}?$").Success)
            {
                GetStatic.JsonResponse(false, Page);
            };
            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create("https://yubin.senmon.net/en/" + zipCode + ".html");
            myRequest.Method = WebRequestMethods.Http.Get;
            WebResponse response = myRequest.GetResponse();
            string json = null;
            using (Stream stream = response.GetResponseStream())
            {
                json = (new StreamReader(stream)).ReadToEnd();
            }
            int length = (json.Length) / 4;
            int indexOfTable = json.IndexOf("<table class=\"info\">");
            int indexOfTableEnd = json.IndexOf("<iframe");
            if (indexOfTable != -1)
            {
                length = indexOfTableEnd - indexOfTable;
            }
            json = json.Substring(indexOfTable, length);
            json = json.Replace("class=\"info\"", "Id=\"info\"");
            GetStatic.JsonResponse(json, Page);
        }

        protected void register_Click(object sender, EventArgs e)
        {
            string eId = GetStatic.ReadQueryString("customerId", "");

            if (!_sl.HasRight(AddFunctionId))
            {
                GetStatic.AlertMessage(this, "You are not authorized to Add Customer!");
                return;
            }
            if (_sl.HasRight(SignatureFunctionId) && (string.IsNullOrEmpty(customerPassword.Text) || string.IsNullOrWhiteSpace(customerPassword.Text)) && (string.IsNullOrEmpty(hddImgURL.Value) || string.IsNullOrWhiteSpace(hddImgURL.Value)))
            {
                GetStatic.AlertMessage(this, "Customer signature or customer password is required!");
                return;
            }
            OnlineCustomerModel customerModel = new OnlineCustomerModel()
            {
                flag = "customer-register-core",
                firstName = firstName.Text,
                middleName = middleName.Text,
                lastName1 = lastName.Text,
                gender = genderList.SelectedValue,
                customerType = hdnCustomerType.Value,
                country = countryList.Text,
                zipCode = zipCode.Text,
                street = txtStreet.Text,
                city = city.Text,
                state = ddlState.Text,
                senderCityjapan = txtsenderCityjapan.Text,
                email = email.Text,
                streetJapanese = txtstreetJapanese.Text,
                homePhone = phoneNumber.Text,
                mobile = mobile.Text,
                visaStatus = ddlVisaStatus.SelectedValue,
                employeeBusinessType = ddlEmployeeBusType.SelectedValue,
                nativeCountry = nativeCountry.SelectedValue,
                dob = dob.Text,
                ssnNo = txtSSnNo.Text,
                sourceOfFound = ddSourceOfFound.SelectedValue,
                occupation = occupation.Text,
                telNo = phoneNumber.Text,
                ipAddress = GetStatic.GetIp(),
                createdBy = GetStatic.GetUser(),
                idNumber = verificationTypeNo.Text,
                idIssueDate = IssueDate.Text,
                idExpiryDate = ExpireDate.Text,
                idType = idType.Text.Split('|')[0].ToString(),
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
                companyName = txtCompanyName.Text,
                MonthlyIncome = ddlSalary.SelectedValue,
                customerPassword = customerPassword.Text
            };

            if (hdnCustomerId.Value != "")
            {
                customerModel.customerId = hdnCustomerId.Value;
                customerModel.flag = "customer-update-new";
            }

            var dbResult = _cd.RegisterCustomerNew(customerModel);
            GetStatic.SetMessage(dbResult.ErrorCode, dbResult.Msg);
            if (dbResult.ErrorCode == "0")
            {
                var customerDetails = _cd.GetRequiredCustomerDetails(dbResult.Id, GetStatic.GetUser());
                string membershipId = Convert.ToString(customerDetails["membershipId"]);
                string registrationDate = Convert.ToString(customerDetails["createdDate"]);
                var verificationCode = dbResult.Id;
                var customerId = dbResult.Id;
                var fileCollection = Request.Files;
                string customerSignature = hddImgURL.Value;
                int ErrorCode = 0;
                if (!string.IsNullOrEmpty(customerSignature) && (dbResult.ErrorCode == "0" || dbResult.ErrorCode == "100" || dbResult.ErrorCode == "101"))
                {
                    UploadSignatureImage(customerSignature, registrationDate, membershipId, customerId, out ErrorCode);
                    if (ErrorCode == 0)
                    {
                        _cd.AddCustomerSignature(customerId, GetStatic.GetUser(), customerId + "_signature.png");
                    }
                }
                for (int i = 0; i < fileCollection.AllKeys.Length; i++)
                {
                    HttpPostedFile file = fileCollection[i];
                    if (file != null)
                    {
                        string documentTypeName = "";
                        string documentTypeValue = "";
                        string fileType = "";
                        if (i == 0)
                        {
                            documentTypeName = "Alien Registration Card(Front)";
                            documentTypeValue = "11054";
                        }
                        else
                        {
                            documentTypeName = "Alien Registration Card(Back)";
                            documentTypeValue = "11055";
                        }
                        var filename = SaveDocument(file, customerId, membershipId, documentTypeName, registrationDate, out fileType, out ErrorCode);
                        if (ErrorCode == 0)
                        {
                            dbResult = _cd.UpdateCustomerDocument("", customerId, filename, "", fileType, documentTypeValue, GetStatic.GetUser());
                        }
                        else
                        {
                            dbResult = new DAL.SwiftDAL.DbResult
                            {
                                Msg = filename,
                                ErrorCode = "1",
                            };
                        }
                    }
                }
                Response.Redirect("AddCustomer.aspx");
                return;
            }
            else
            {
                if (hdnCustomerType.Value == "4701")
                {
                    ddlCustomerType.SelectedValue = hdnCustomerType.Value;
                }
                return;
            }
        }

        private string SaveDocument(HttpPostedFile doc, string customerId, string membershipId, string documentName, string registerDate, out string fileType, out int ErrorCode)
        {
            var maxFileSize = GetStatic.ReadWebConfig("csvFileSize", "2097152");
            fileType = "";
            ErrorCode = 0;
            string fName = "";
            try
            {
                fileType = doc.ContentType;
                if (false)
                //if (doc.ContentLength > Convert.ToDouble(maxFileSize))
                {
                    fName = "File size is too large";
                    ErrorCode = 1;
                }
                else
                {
                    //generate filename
                    string fileExtension = new FileInfo(doc.FileName).Extension;
                    string fileName = customerId + "_" + documentName + "_" + DateTime.Now.Hour.ToString() + DateTime.Now.Millisecond.ToString() + "_" + registerDate.Replace("-", "_") + fileExtension;
                    fName = fileName;

                    string tempFilePath = GetStatic.GetCustomerFilePath() + "CustomerDocument\\TempFiles\\";

                    //save file
                    string path = GetStatic.GetCustomerFilePath() + "CustomerDocument\\" + registerDate.Replace("-", "\\") + "\\" + membershipId;
                    if (!Directory.Exists(tempFilePath))
                        Directory.CreateDirectory(tempFilePath);
                    doc.SaveAs(tempFilePath + fileName);
                    if (!Directory.Exists(path))
                        Directory.CreateDirectory(path);
                    //reduce file size
                    using (Bitmap bitmapObj = new Bitmap(tempFilePath + fileName))
                    {
                        var fileProp = System.Drawing.Image.FromFile(tempFilePath + fileName);
                        Bitmap reduceBitmapImg = new Bitmap(bitmapObj, fileProp.Width / 3, fileProp.Height / 3);
                        reduceBitmapImg.Save(path + "/" + fileName, ImageFormat.Jpeg);
                        fileProp.Dispose();
                    }
                    //delete file
                    File.Delete(tempFilePath + fileName);
                }
            }
            catch (Exception ex)
            {
                fName = ex.Message;
                ErrorCode = 1;
            }
            return fName;
        }

        public void UploadSignatureImage(string imageData, string registerDate, string membershipId, string customerId, out int errorCode)
        {
            try
            {
                errorCode = 0;
                string path = GetStatic.ReadWebConfig("customerDocPath", "") + "CustomerDocument\\" + registerDate.Replace("-", "\\") + "\\" + membershipId;
                if (!Directory.Exists(path))
                    Directory.CreateDirectory(path);

                string fileName = path + "\\" + customerId + "_signature" + ".png";
                using (FileStream fs = new FileStream(fileName, FileMode.Create))
                {
                    using (BinaryWriter bw = new BinaryWriter(fs))
                    {
                        byte[] data = Convert.FromBase64String(imageData);
                        bw.Write(data);
                        bw.Close();
                    }
                }
            }
            catch (Exception)
            {
                errorCode = 1;
            }
        }
    }
}