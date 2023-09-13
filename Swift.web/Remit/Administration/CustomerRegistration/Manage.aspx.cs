using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.CustomerRegistration
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        private const string AddViewFunctionId = "20212000";
        private const string EditViewFunctionId = "20212020";
        private const string AddFunctionId = "20212010";
        private const string EditFunctionId = "20212020";
        private bool isEdit = Convert.ToBoolean(GetStatic.ReadQueryString("edit", "false"));

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            GetStatic.PrintMessage(Page);
            displayOnlyOnEdit.Visible = CheckAddOrEdit();
            var MethodName = Request.Form["MethodName"];

            if (!IsPostBack)
            {
                if (string.IsNullOrWhiteSpace(MethodName))
                {
                    PopulateDdl();
                }

                Authenticate();
                if (MethodName == "GetCustomerDetails")
                {
                    GetCustomerDetails();
                }
                if (MethodName == "PopulateCity")
                {
                    PopulateCity();
                }
                if (MethodName == "PopulateProvince")
                {
                    PopulateProvince();
                }
                if (MethodName == "PopulateIdType")
                {
                    PopulateIdType();
                }
            }
        }

        private void Authenticate()
        {
            if (CheckAddOrEdit())
                _sl.CheckAuthentication(EditViewFunctionId);
            else
                _sl.CheckAuthentication(AddViewFunctionId);

            string eId = GetStatic.ReadQueryString("customerId", "");

            var hasRight = true;
            if (eId == "")
            {
                hasRight = _sl.HasRight(AddFunctionId);
                register.Enabled = hasRight;
                register.Visible = hasRight;
            }
            else
            {
                hasRight = _sl.HasRight(EditFunctionId);
                register.Enabled = hasRight;
                register.Visible = hasRight;
            }
        }

        public bool CheckAddOrEdit()
        {
            return isEdit;
        }

        private void PopulateDdl()
        {
            _sl.SetDDL(ref genderList, "EXEC proc_online_dropDownList @flag='GenderList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref countryList, "EXEC proc_online_dropDownList @flag='onlineCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "");
            _sl.SetDDL(ref nativeCountry, "EXEC proc_online_dropDownList @flag='allCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "142", "");
            _sl.SetDDL(ref occupation, "EXEC proc_online_dropDownList @flag='occupationList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref idType, "EXEC proc_online_dropDownList @flag='IdTypeWithDetails',@user='" + GetStatic.GetUser() + "',@countryId='" + nativeCountry.SelectedValue + "'", "valueId", "detailTitle", "8008|National ID|N", "");
            _sl.SetDDL(ref ddSourceOfFound, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3900", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlVisaStatus, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7005", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref district, "EXEC proc_online_dropDownList @flag='province',@countryId='" + nativeCountry.SelectedValue + "'", "id", "PROVINCE_NAME", "", "Select..");
            _sdd.SetDDL(ref ddlCity, "EXEC proc_online_dropDownList @flag='city',@provinceId=" + _sdd.FilterString(district.SelectedValue), "id", "CITY_NAME", "", "Select..");
            _sl.SetDDL(ref bankName, "EXEC proc_online_dropDownList @flag='bank',@user='" + GetStatic.GetUser() + "'", "id", "BankName", "", "Select..");
            _sdd.SetDDL(ref ddlSearchBy, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
        }

        protected void register_Click(object sender, EventArgs e)
        {
            string eId = GetStatic.ReadQueryString("customerId", "");

            if (eId == "")
            {
                if (!_sl.HasRight(AddFunctionId))
                {
                    GetStatic.AlertMessage(this, "You are not authorized to Add Customer!");
                    return;
                }
            }
            else
            {
                if (!_sl.HasRight(EditFunctionId))
                {
                    GetStatic.AlertMessage(this, "You are not authorized to Edit Customer!");
                    return;
                }
            }

            if (hddTxnsMade.Value == "Y" && (!email.Text.Equals(hddOldEmailValue.Value.ToString())))
            {
                GetStatic.AlertMessage(this, "You can not change the email of customer who have already done transaction!");
                return;
            }
            string trimmedfirstName = firstName.Text.Trim() == "" ? null : firstName.Text.Trim();
            var cityValue = Request.Form["ddlCity"];

            if (!string.IsNullOrWhiteSpace(ddlCity.SelectedValue))
            {
                cityValue = ddlCity.SelectedValue;
            }

            if (string.IsNullOrWhiteSpace(cityValue))
            {
                cityValue = Request.Form["ctl00$ContentPlaceHolder1$ddlCity"];
            }

            string trimmedlastName = lastName.Text.Trim() == "" ? null : lastName.Text.Trim();

            OnlineCustomerModel customerModel = new OnlineCustomerModel()
            {
                flag = "customer-register-core",
                firstName = trimmedfirstName,
                lastName1 = trimmedlastName,
                gender = genderList.SelectedValue,
                country = countryList.Text,
                address = txtAdditionalAddress.Text,
                city = cityValue,
                bankName = bankName.SelectedValue,
                accountNumber = bankAccountNo.Text,
                district = district.SelectedValue,
                mobile = mobile.Text,
                visaStatus = ddlVisaStatus.SelectedValue,
                email = email.Text,
                nativeCountry = nativeCountry.SelectedValue,
                dob = dob.Text,
                sourceOfFound = ddSourceOfFound.SelectedValue,
                occupation = occupation.Text,
                ipAddress = GetStatic.GetIp(),
                createdBy = GetStatic.GetUser(),
                idNumber = verificationTypeNo.Text,
                idIssueDate = IssueDate.Text,
                idExpiryDate = ExpireDate.Text,
                idType = idType.Text.Split('|')[0].ToString(),
                agentId = GetStatic.GetAgent().ToInt(),
            };

            if (hdnCustomerId.Value != "")
            {
                customerModel.customerId = hdnCustomerId.Value;
                customerModel.flag = "customer-editeddata";
            }
            var dbResult = _cd.RegisterCustomerNew(customerModel);
            if (dbResult.ErrorCode == "0")
            {
                var customerDetails = _cd.GetRequiredCustomerDetails(dbResult.Id, GetStatic.GetUser());
                var customerId = dbResult.Id;
                string membershipId = Convert.ToString(customerDetails["membershipId"]);
                string registrationDate = Convert.ToString(customerDetails["createdDate"]);
                string selfieImage = selfieImageFile.FileName != "" ? UploadImage(selfieImageFile, registrationDate, membershipId, customerId, "selfie_With_Id") : "";
                string passName = passImageFile.FileName != "" ? UploadImage(passImageFile, registrationDate, membershipId, customerId, "passport") : "";
                string idFront = frontIdImageFile.FileName != "" ? UploadImage(frontIdImageFile, registrationDate, membershipId, customerId, "Id_Front") : "";
                string idBack = backIdImageFile.FileName != "" ? UploadImage(backIdImageFile, registrationDate, membershipId, customerId, "Id_Back") : "";
                OnlineCustomerModel onlineCustomer = new OnlineCustomerModel()
                {
                    customerId = dbResult.Id,
                    flag = "fileUpload",
                    verifyDoc1 = passName == "" ? null : passName,
                    verifyDoc2 = idFront == "" ? null : idFront,
                    verifyDoc3 = idBack == "" ? null : idBack,
                    verifyDoc4 = selfieImage == "" ? null : selfieImage
                };
                _cd.AddAndUpdateCustomerDocument(onlineCustomer);
            }
            GetStatic.SetMessage(dbResult.ErrorCode, dbResult.Msg);
            if (dbResult.ErrorCode == "0")
            {
                string memberId = "";
                if (dbResult.Msg.Split(':').Length > 1)
                {
                    memberId = dbResult.Msg.Split(':')[1].Trim();
                }

                hdnCustomerId.Value = null;
                if (CheckAddOrEdit())
                {
                    Response.Redirect("Manage.aspx?edit=true&hdnId=" + memberId + "");
                }
                else
                {
                    Response.Redirect("Manage.aspx?hdnId=" + memberId + "");
                }
            }
            Page_Load(sender, e);
            return;
        }

        public string UploadImage(FileUpload doc, string registerDate, string membershipId, string customerId, string idTypeName)
        {
            try
            {
                string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
                string DocumentExtension = GetStatic.ReadWebConfig("customerDocFileExtension", "");
                string rootPath = GetStatic.GetCustomerFilePath();
                string folderPath = Path.Combine(rootPath, "CustomerDocument", registerDate.Replace("-", "\\"), membershipId);
                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);
                string fileName = customerId + "_" + idTypeName + fileExtension;
                string filePath = Path.Combine(folderPath, fileName);
                doc.SaveAs(filePath);
                return fileName;
            }
            catch (Exception)
            {
                return "";
            }
        }

        private void GetCustomerDetails()
        {
            string eId = Request.Form["Id"];
            var dt = _cd.GetDetailsForEditCustomer(eId, GetStatic.GetUser());
            Response.ContentType = "text/plain";
            string membershipNo = dt.Rows[0]["membershipId"].ToString();
            string registerDate = dt.Rows[0]["createdDate"].ToString();
            var passImage = "/Remit/GetFileView.ashx?registerDate=" + registerDate + "&membershipNo=" + membershipNo + "&fileName=" + dt.Rows[0]["verifyDoc1"].ToString();
            var idFrontImage = "/Remit/GetFileView.ashx?registerDate=" + registerDate + "&membershipNo=" + membershipNo + "&fileName=" + dt.Rows[0]["verifyDoc2"].ToString();
            var idBackImage = "/Remit/GetFileView.ashx?registerDate=" + registerDate + "&membershipNo=" + membershipNo + "&fileName=" + dt.Rows[0]["verifyDoc3"].ToString();
            var selfieImage = "/Remit/GetFileView.ashx?registerDate=" + registerDate + "&membershipNo=" + membershipNo + "&fileName=" + dt.Rows[0]["verifyDoc4"].ToString();

            dt.Rows[0]["verifyDoc1"] = passImage;
            dt.Rows[0]["verifyDoc2"] = idFrontImage;
            dt.Rows[0]["verifyDoc3"] = idBackImage;
            dt.Rows[0]["verifyDoc4"] = selfieImage;
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void PopulateCity()
        {
            string provinceId = Request.Form["provinceId"];
            var dt = _cd.GetCity(provinceId);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void PopulateProvince()
        {
            string nativeId = Request.Form["nativeId"];
            var dt = _cd.GetProvince(nativeId);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void PopulateIdType()
        {
            string nativeId = Request.Form["nativeId"];
            var dt = _cd.GetIdType(nativeId, GetStatic.GetUser());
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }
    }
}