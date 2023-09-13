using Newtonsoft.Json;
using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.OnlineAgent;
using Swift.DAL.Remittance.Administration.ReceiverInformation;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.CustomerSetup.Benificiar
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly ReceiverInformationDAO _receiver = new ReceiverInformationDAO();
        private SendTranIRHDao st = new SendTranIRHDao();
        private const string ViewFunctionId = "20206000";
        private const string AddFunctionId = "20206010";
        private const string EditFunctionId = "20206020";
        private const string sendPageFunctionId = "20206030";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (GetReceiverAddType().ToLower() == "s")
            {
                receiverList.Visible = false;
            }
            _sl.CheckSession();
            receiverAccountNo.Attributes.Add("hidden", "hidden");
            if (!IsPostBack)
            {
                hideSearchDiv();
                string reqMethod = Request.Form["MethodName"];
                switch (reqMethod)
                {
                    case "PaymentModePcountry":
                        LoadPaymentModeFromAjax();
                        break;

                    case "PopulatePaymentMode":
                        LoadPaymentModeDDL();
                        break;

                    case "PopulatePayoutPartner":
                        LoadPayoutPartner();
                        break;

                    case "SaveReceiverDetails":
                        SaveReceiverDetails();
                        break;

                    case "GetBankBranch":
                        GetBankBranch();
                        break;
                }
                Authenticate();
                var a = otherRelationshipTextBox.Text;
                if (a == "")
                {
                    otherRelationDiv.Attributes.Add("style", "display:none");
                }
                string customerId = GetStatic.ReadQueryString("customerId", "");
                var result = _cd.GetCustomerDetails(customerId, GetStatic.GetUser());
                if (result != null)
                {
                    hideCustomerId.Value = customerId;
                    hideMembershipId.Value = result["membershipId"].ToString();
                    txtCustomerName.InnerText = result["firstName"].ToString() + ' ' + result["middleName"].ToString() + ' ' + result["lastName1"].ToString();
                }

                string receiverId = GetStatic.ReadQueryString("receiverId", "");
                PopulateDDL();
                if (receiverId != "")
                {
                    PopulateForm(receiverId);
                }
            }
        }

        private void hideSearchDiv()
        {
            var hide = GetStatic.ReadQueryString("hideSearchDiv", "").ToString();
            if (hide == "true")
            {
                hideSearchDivVal.Value = "true";
            }
        }

        private void SaveReceiverDetails()
        {
            string receiverId = GetStatic.ReadQueryString("receiverId", "");

            var PaymentModeValue = Request.Form["paymentMode"].ToString();

            var trimmedReceiverFName = Request.Form["ReceiverFName"].ToString().ToUpper().Trim() == "" ? null : Request.Form["ReceiverFName"].ToString().ToUpper().Trim();
            var trimmedReceiverMName = Request.Form["ReceiverMName"].ToString().ToUpper().Trim() == "" ? null : Request.Form["ReceiverMName"].ToString().ToUpper().Trim();
            var trimmedReceiverLName = Request.Form["ReceiverLName"].ToString().ToUpper().Trim() == "" ? null : Request.Form["ReceiverLName"].ToString().ToUpper().Trim();

            BenificiarData benificiar = new BenificiarData();

            string Country = Request.Form["Country"].ToString();
            benificiar.Country = Country.Split('(')[0];
            benificiar.NativeCountry = Request.Form["nativeCountry"].ToString();
            benificiar.BenificiaryType = Request.Form["BenificiaryType"].ToString();
            benificiar.Email = Request.Form["Email"].ToString().ToUpper();
            benificiar.ReceiverFName = trimmedReceiverFName;
            benificiar.ReceiverMName = trimmedReceiverMName;
            benificiar.ReceiverLName = trimmedReceiverLName;
            benificiar.ReceiverAddress = Request.Form["ReceiverAddress"].ToString().ToUpper();
            benificiar.ReceiverCity = Request.Form["ReceiverCity"].ToString().ToUpper();
            benificiar.ContactNo = Request.Form["ContactNo"].ToString();
            benificiar.SenderMobileNo = Request.Form["SenderMobileNo"].ToString();
            benificiar.Relationship = Request.Form["Relationship"].ToString();
            benificiar.PlaceOfIssue = Request.Form["PlaceOfIssue"].ToString().ToUpper();
            benificiar.TypeId = Request.Form["TypeId"].ToString();
            benificiar.TypeValue = Request.Form["TypeValue"].ToString();
            benificiar.PurposeOfRemitance = Request.Form["PurposeOfRemitance"].ToString();
            benificiar.PaymentMode = Request.Form["PaymentMode"].ToString();
            benificiar.PayoutPatner = Request.Form["PayoutPatner"].ToString();
            benificiar.BenificaryAc = Request.Form["BenificaryAc"].ToString();
            benificiar.BankLocation = Request.Form["BankLocation"].ToString().ToUpper();
            benificiar.BankName = Request.Form["BankName"].ToString().ToUpper();
            benificiar.BenificaryAc = Request.Form["BenificaryAc"].ToString();
            benificiar.Remarks = Request.Form["Remarks"].ToString().ToUpper();
            benificiar.OtherRelationDescription = Request.Form["OtherRelationDescription"].ToString().ToUpper();
            benificiar.membershipId = Request.Form["membershipId"].ToString();
            benificiar.ReceiverId = Request.Form["ReceiverId"].ToString();
            benificiar.customerId = (Request.Form["hideCustomerId"].ToString() != "" ? Request.Form["hideCustomerId"].ToString() : null);
            benificiar.agentId = GetStatic.GetAgent().ToInt();
            benificiar.Flag = (Request.Form["hideBenificialId"].ToString() != "" ? "u" : "i");

      benificiar.isOrg = Convert.ToInt32(Request.Form["isOrg"].ToString());
      benificiar.bIkk = Request.Form["bIkk"].ToString();
      benificiar.bInn = Request.Form["bInn"].ToString();

      var dbResult = _cd.UpdateBenificiarInformation(benificiar, GetStatic.GetUser());
            if (dbResult.ErrorCode == "0")
            {
                if (GetReceiverAddType().ToLower() != "s")
                {
                    GetStatic.SetMessage(dbResult);
                }
            }
            var jsonString = JsonConvert.SerializeObject(dbResult);
            Response.ContentType = "application/json";
            Response.Write(jsonString);
            Response.End();
        }

        private void LoadPayoutPartner()
        {
            var countryId = Request.Form["country"].Split('(')[0];
            var paymentModeVal = Request.Form["paymentMode"];
            var sql = "EXEC proc_sendPageLoadData @flag='recAgentByRecModeAjaxagentAndCountry', @countryId = '" + GetStatic.ReadWebConfig("domesticCountryId", "") + "',@pCountryId='" + countryId + "',@param = '" + paymentModeVal + "',@agentId='" + GetStatic.GetAgentId() + "',@user = '" + GetStatic.GetUser() + "'";
            var payoutPartnerList = _cd.ExecuteDataTable(sql);
            var payoutPartnerDdl = Mapper.DataTableToClass<DropDownModel>(payoutPartnerList);
            var jsonString = JsonConvert.SerializeObject(payoutPartnerDdl);
            Response.ContentType = "application/json";
            Response.Write(jsonString);
            Response.End();
        }

        private void LoadPaymentModeDDL()
        {
            var country = Request.Form["country"];
            var sql = "EXEC proc_online_sendPageLoadData @flag='payoutMethods'";
            sql += ",@country=" + _cd.FilterString(country.Split('(')[0]);
            var paymentList = _cd.ExecuteDataTable(sql);
            var paymentDdl = Mapper.DataTableToClass<DropDownModel>(paymentList);
            var jsonString = JsonConvert.SerializeObject(paymentDdl);
            Response.ContentType = "application/json";
            Response.Write(jsonString);
            Response.End();
        }

        public static class Mapper
        {
            public static IList<T> DataTableToClass<T>(DataTable Table) where T : class, new()
            {
                var dataList = new List<T>(Table.Rows.Count);
                Type classType = typeof(T);
                IList<PropertyInfo> propertyList = classType.GetProperties();
                if (propertyList.Count == 0)
                    return new List<T>();
                List<string> columnNames = Table.Columns.Cast<DataColumn>().Select(column => column.ColumnName).ToList();
                try
                {
                    foreach (DataRow dataRow in Table.AsEnumerable().ToList())
                    {
                        var classObject = new T();
                        foreach (PropertyInfo property in propertyList)
                        {
                            if (property != null && property.CanWrite)
                            {
                                if (columnNames.Contains(property.Name))
                                {
                                    if (dataRow[property.Name] != System.DBNull.Value)
                                    {
                                        object propertyValue = System.Convert.ChangeType(
                                                dataRow[property.Name],
                                                property.PropertyType
                                            );
                                        property.SetValue(classObject, propertyValue, null);
                                    }
                                }
                            }
                        }
                        dataList.Add(classObject);
                    }
                    return dataList;
                }
                catch
                {
                    return new List<T>();
                }
            }
        }

        private void Authenticate()
        {
            if (GetReceiverAddType().ToLower() == "s")
            {
                _sl.CheckAuthentication(sendPageFunctionId);
            }
            else
            {
                _sl.CheckAuthentication(ViewFunctionId);
            }

            string receiverId = GetStatic.ReadQueryString("receiverId", "");

            if (receiverId == "")
            {
                register.Enabled = _sl.HasRight(AddFunctionId);
                register.Visible = _sl.HasRight(AddFunctionId);
            }
            else
            {
                register.Enabled = _sl.HasRight(EditFunctionId);
                register.Visible = _sl.HasRight(EditFunctionId);
            }
        }

        protected string GetReceiverId()
        {
            return GetStatic.ReadQueryString("receiverId", "");
        }

        private void PopulateForm(string id)
        {
            var dr = _receiver.SelectReceiverInformationByReceiverId(GetStatic.GetUser(), id);
            if (null != dr)
            {
                string countryId = dr["countryId"].ToString();
                ddlCountry.SelectedValue = countryId;
                ddlBenificiaryType.SelectedValue = dr["receiverType"].ToString();
                txtEmail.Text = dr["email"].ToString();
                txtReceiverFName.Text = dr["firstName"].ToString();
                txtReceiverLName.Text = dr["lastName1"].ToString();
                txtReceiverMName.Text = dr["middleName"].ToString();
                txtReceiverAddress.Text = dr["address"].ToString();
                txtReceiverCity.Text = dr["city"].ToString();
                txtContactNo.Text = dr["homePhone"].ToString();
                txtSenderMobileNo.Text = dr["mobile"].ToString();

                txtPlaceOfIssue.Text = dr["placeOfIssue"].ToString();
                ddlIdType.SelectedValue = dr["idType"].ToString();
                txtIdValue.Text = dr["idNumber"].ToString();
                ddlPurposeOfRemitance.SelectedValue = dr["purposeOfRemit"].ToString();
                DDLBankBranch.SelectedValue = dr["bankLocation"].ToString();
                txtBankName.Text = dr["bankName"].ToString();
                txtBenificaryAc.Text = dr["receiverAccountNo"].ToString();
                txtRemarks.Text = dr["remarks"].ToString();
                hideCustomerId.Value = dr["customerId"].ToString();
                hideBenificialId.Value = dr["receiverId"].ToString();
                hideMembershipId.Value = dr["membershipId"].ToString();
                ddlNativeCountry.SelectedValue = dr["NativeCountry"].ToString();
                ddlRelationship.SelectedValue = dr["relationship"].ToString();
                //if (dr["bankLocation"].ToString() == "")
                //{
                //    agentBankBranchDiv.Attributes.Add("style", "display: none;");
                //}
                if (dr["relationship"].ToString() == "11081")
                {
                    otherRelationDiv.Attributes.Add("style", "");
                    otherRelationshipTextBox.Text = dr["otherRelationDesc"].ToString();
                }
                else
                {
                    otherRelationDiv.Attributes.Add("style", "display: none;");
                }
                LoadPaymentModeDDL(dr["paymentMode"].ToString());
                LoadPayoutPartnerDDL(dr["payOutPartner"].ToString());
                LoadPayoutPartnerBranchDDL(dr["payOutPartner"].ToString(), countryId, dr["paymentMode"].ToString(), dr["bankLocation"].ToString());
            }
        }

        private void PopulateDDL()
        {
            _sl.SetDDL(ref ddlIdType, "EXEC proc_online_dropDownList @flag='idType',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlCountry, "EXEC proc_online_dropDownList @flag='allCountrylistWithCode',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "Select..");
            _sl.SetDDL(ref ddlNativeCountry, "EXEC proc_online_dropDownList @flag='allCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "Select..");
            _sl.SetDDL(ref ddlRelationship, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=2100", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlPurposeOfRemitance, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3800", "valueId", "detailTitle", "8060", "Select..");
            _sl.SetDDL(ref ddlBenificiaryType, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=4700", "valueId", "detailTitle", ddlBenificiaryType.SelectedValue, "");
        }

        protected void register_Click(object sender, EventArgs e)
        {
            string receiverId = GetStatic.ReadQueryString("receiverId", "");

            BenificiarData benificiar = new BenificiarData()
            {
                Country = ddlCountry.SelectedItem.Text.Split('(')[0],
                NativeCountry = ddlNativeCountry.SelectedValue,
                BenificiaryType = ddlBenificiaryType.SelectedValue,
                Email = txtEmail.Text,
                ReceiverFName = txtReceiverFName.Text,
                ReceiverMName = txtReceiverMName.Text,
                ReceiverLName = txtReceiverLName.Text,
                ReceiverAddress = txtReceiverAddress.Text,
                ReceiverCity = txtReceiverCity.Text,
                ContactNo = txtContactNo.Text,
                SenderMobileNo = txtSenderMobileNo.Text,
                Relationship = ddlRelationship.SelectedItem.Text,
                PlaceOfIssue = txtPlaceOfIssue.Text,
                TypeId = ddlIdType.SelectedValue,
                TypeValue = txtIdValue.Text,
                PurposeOfRemitance = ddlPurposeOfRemitance.SelectedItem.Text,
                PaymentMode = ddlPaymentMode.SelectedValue,
                PayoutPatner = ddlPayoutPatner.SelectedValue,
                BankLocation = DDLBankBranch.SelectedValue,
                BankName = txtBankName.Text,
                BenificaryAc = txtBenificaryAc.Text,
                Remarks = txtRemarks.Text,
                OtherRelationDescription = otherRelationshipTextBox.Text,
                membershipId = hideMembershipId.Value,
                ReceiverId = hideBenificialId.Value,
                customerId = (hideCustomerId.Value != "" ? hideCustomerId.Value : null),
                Flag = (hideBenificialId.Value != "" ? "u" : "i"),
                isOrg = Convert.ToInt32(Request.Form["isOrg"].ToString()),
                bIkk = Request.Form["bIkk"].ToString(),
                bInn = Request.Form["bInn"].ToString()
    };
            var dbResult = _cd.UpdateBenificiarInformation(benificiar, GetStatic.GetUser());
            if (dbResult.ErrorCode == "0")
            {
                if (GetReceiverAddType().ToLower() == "s")
                {
                    GetStatic.CallBackJs1(Page, "Call Back", "CallBack('" + dbResult.Id + "');");
                }
                else
                {
                    GetStatic.SetMessage(dbResult);
                    Response.Redirect("List.aspx?customerId=" + benificiar.customerId);
                    return;
                }
            }
            else
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
            }
        }

        public string GetReceiverAddType()
        {
            return GetStatic.ReadQueryString("AddType", "");
        }

        private void LoadPaymentModeDDL(string paymentId)
        {
            _sl.SetDDL(ref ddlPaymentMode, "EXEC proc_online_sendPageLoadData @flag='payoutMethods',@country='" + ddlCountry.SelectedItem.Text.Split('(')[0] + "'", "Key", "Value", paymentId, "");
        }

        private void LoadPaymentModeFromAjax()
        {
            var pCountry = Request.Form["pCountry"];
            var dt = _cd.LoadDataPaymentModeDdl(GetStatic.ReadWebConfig("domesticCountryId", ""), pCountry, "", null, "recModeByCountry", GetStatic.GetUser());
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

        protected void ddlCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(ddlCountry.SelectedItem.Text))
            {
                LoadPaymentModeDDL("");
                LoadPayoutPartnerDDL(ddlPayoutPatner.SelectedValue);
            }
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        private void LoadPayoutPartnerDDL(string partnerId)
        {
            _sl.SetDDL(ref ddlPayoutPatner, "EXEC proc_sendPageLoadData @flag='recAgentByRecModeAjaxagentAndCountry', @countryId = '" + GetStatic.ReadWebConfig("domesticCountryId", "") + "',@pCountryId='" + ddlCountry.SelectedValue + "',@param = '" + ddlPaymentMode.SelectedItem.Text + "',@agentId='" + GetStatic.GetAgentId() + "',@user = '" + GetStatic.GetUser() + "'", "bankId", "AGENTNAME", partnerId, "");
            if (ddlPaymentMode.SelectedValue == "2")
                receiverAccountNo.Attributes.Remove("hidden");
        }

        private void LoadPayoutPartnerBranchDDL(string bankId, string countryId, string pMode, string branchId)
        {
            if (pMode == "2")
                receiverAccountNo.Attributes.Remove("hidden");

            var dtResult = st.GetPayoutPartner(GetStatic.GetUser(), countryId, pMode);
            string partnerId = "";
            if (dtResult.Rows.Count > 0)
            {
                partnerId = dtResult.Rows[0][0].ToString();
            }
            var dao = new RemittanceDao();
            string sql = "";
            if (partnerId == GetStatic.ReadWebConfig("transfast", "") || partnerId == GetStatic.ReadWebConfig("jmeNepal", ""))
            {
                sql = "EXEC PROC_API_BANK_BRANCH_SETUP @FLAG='getBranchByAgentIdForDDL',@bankId=" + dao.FilterString(bankId) + ",@PAYMENT_TYPE = " + dao.FilterString(pMode);
            }
            else
            {
                sql = "EXEC proc_dropDownLists @flag = 'pickBranchById', @agentId=" + dao.FilterString(bankId);
            }
            _sl.SetDDL(ref DDLBankBranch, sql, "agentId", "agentName", branchId, "");
        }

        protected void ddlPayoutPatner_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPayoutPartnerBranchDDL(ddlPayoutPatner.SelectedValue, ddlCountry.SelectedValue, ddlPaymentMode.SelectedValue, null);
        }

        public void GetBankBranch()
        {
            string bankId = Request.Form["bankId"];
            string countryId = Request.Form["countryId"];
            string pMode = Request.Form["pMode"];
            string branchId = Request.Form["branchId"];
            if (pMode == "2")
                receiverAccountNo.Attributes.Remove("hidden");

            var dtResult = st.GetPayoutPartner(GetStatic.GetUser(), countryId, pMode);
            string partnerId = dtResult.Rows[0][0].ToString();
            var dao = new RemittanceDao();
            string sql = "";
            if (partnerId == GetStatic.ReadWebConfig("transfast", "") || partnerId == GetStatic.ReadWebConfig("jmeNepal", ""))
            {
                sql = "EXEC PROC_API_BANK_BRANCH_SETUP @FLAG='getBranchByAgentIdForDDL',@bankId=" + dao.FilterString(bankId) + ",@PAYMENT_TYPE = " + dao.FilterString(pMode);
            }
            else
            {
                sql = "EXEC proc_dropDownLists @flag = 'pickBranchById', @agentId=" + dao.FilterString(bankId);
            }
            var paymentDdl = Mapper.DataTableToClass<DropDownModel>(_sl.ExecuteDataTable(sql));
            var jsonString = JsonConvert.SerializeObject(paymentDdl);
            Response.ContentType = "application/json";
            Response.Write(jsonString);
            Response.End();
        }
    }

    public class DropDownModel
    {
        public string Key { get; set; }
        public string Value { get; set; }
        public string bankId { get; set; }
        public string AGENTNAME { get; set; }
        public string agentId { get; set; }
        public string agentName { get; set; }
    }
}