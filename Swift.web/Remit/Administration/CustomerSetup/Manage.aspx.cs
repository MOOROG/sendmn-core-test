using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Net;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;

using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;

namespace Swift.web.Remit.Administration.customerSetup {
 public partial class Manage : Page {
  private readonly RemittanceLibrary _sl = new RemittanceLibrary();
  private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
  private readonly StaticDataDdl _sdd = new StaticDataDdl();
  private const string ViewFunctionId = "20111300";
  private const string AddFunctionId = "20111310";
  private const string EditFunctionId = "20111320";

  private const string ViewFunctionIdAdmin = "20130000";
  private const string AddFunctionIdAdmin = "20130040";
  private const string EditFunctionIdAdmin = "20130040";
  private const string visibleTrue = "display:none";
  private const string visibleFalse = "display:'';";

  protected void Page_Load(object sender, EventArgs e) {
   _sl.CheckSession();
   displayOnlyOnEdit.Attributes.Add("style", visibleFalse);
   var MethodName = Request.Form["MethodName"];
   if(!IsPostBack) {
    Authenticate();
    PopulateDdl();
    string eId = GetStatic.ReadQueryString("customerId", "");
    if(eId != "") {
     PopulateForm(eId);
     DisableFields();
    }
    if(MethodName == "PopulateCity") {
     PopulateCity();
    }
    if(MethodName == "PopulateProvince") {
     PopulateProvince();
    }
    if(MethodName == "PopulateIdType") {
     PopulateIdType();
    }
   }
  }

  private void Authenticate() {
   _sl.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionId, ViewFunctionIdAdmin));

   string eId = GetStatic.ReadQueryString("customerId", "");

   var hasRight = false;
   if(eId == "") {
    hasRight = _sl.HasRight(GetFunctionIdByUserType(AddFunctionId, AddFunctionIdAdmin));
    register.Enabled = hasRight;
    register.Visible = hasRight;
   } else {
    hasRight = _sl.HasRight(GetFunctionIdByUserType(EditFunctionId, EditFunctionIdAdmin));
    register.Enabled = hasRight;
    register.Visible = hasRight;
   }
  }

  private void DisableFields() {
  }

  private void PopulateForm(string eId) {
   var dr = _cd.GetCustomerDetails(eId, GetStatic.GetUser());
   if(null != dr) {
    string registerDate = dr["createdDate"].ToString();
    string membershipNo = dr["membershipId"].ToString();
    displayOnlyOnEdit.Attributes.Add("style", visibleTrue);
    txtMembershipId.Text = membershipNo;
    txtMembershipId.Attributes.Add("readonly", "readonly");
    ddSourceOfFound.SelectedValue = dr["sourceOfFund"].ToString();
    genderList.SelectedValue = dr["gender"].ToString();
    hdnCustomerId.Value = dr["customerId"].ToString();
    nativeCountry.SelectedValue = dr["nativeCountryId"].ToString();
    district.SelectedValue = dr["district"].ToString();
    mobile.Text = dr["mobile"].ToString();
    firstName.Text = dr["firstName"].ToString();
    lastName.Text = dr["lastName1"].ToString();
    countryList.SelectedValue = dr["country"].ToString();
    txtAdditionalAddress.Text = dr["additionalAddress"].ToString();
    email.Text = dr["email"].ToString();
    hddOldEmailValue.Value = dr["email"].ToString();
    bankName.SelectedValue = dr["bankName"].ToString();
    bankAccountNo.Text = dr["bankAccountNo"].ToString();
    dob.Text = dr["dob"].ToString();
    occupation.Text = dr["occupation"].ToString();
    IssueDate.Text = dr["idIssueDate"].ToString();
    ExpireDate.Text = dr["idExpiryDate"].ToString();
    idType.SelectedValue = dr["idType"].ToString();
    verificationTypeNo.Text = dr["idNumber"].ToString();
    hddIdNumber.Value = dr["homePhone"].ToString();
    hdnMembershipNo.Value = dr["membershipId"].ToString();
    ddlVisaStatus.SelectedValue = dr["visaStatus"].ToString();
    email.Enabled = (dr["isTxnMade"].ToString() == "Y") ? false : true;
    username.Text = dr["username"].ToString();
    occupType.SelectedValue = dr["occupType"].ToString();
    isOrg.SelectedValue = dr["customerType"].ToString();
    hddTxnsMade.Value = dr["isTxnMade"].ToString();
    if(dr["nonMonPep"].ToString() == "1")
     nonMonPep.Checked = true;

    //if (dr["idType"].ToString() == "8008" && dr["nativeCountry"].ToString() != "142")
    //{
    //    expiryDiv.Attributes.Add("style", "display:none;");
    //    //expiryDiv.Attributes.Add("style", visibleFalse);
    //}
    //else
    //{
    //    expiryDiv.Attributes.Add("style", "display:block;");
    //    //expiryDiv.Attributes.Add("style", visibleTrue);
    //}
    _sdd.SetDDL(ref ddlCity, "EXEC proc_online_dropDownList @flag='city',@provinceId=" + _sdd.FilterString(district.SelectedValue), "id", "CITY_NAME", "", "Select..");
    membershipDiv.Attributes.Add("style", visibleTrue);
    ddlCity.SelectedValue = dr["city"].ToString();
    var drr = _cd.GetBlackListAccount(bankAccountNo.Text);
    if(null != drr) {
     holdReasonTxt.Text = drr["rsnTxt"].ToString();
     isHold.Checked = drr["holdFlg"].ToString().Equals("1") ? true : false;
    }
    ShowImage(dr["verifyDoc4"].ToString(), dr["verifyDoc1"].ToString(), dr["verifyDoc2"].ToString(), dr["verifyDoc3"].ToString(), registerDate, membershipNo);
   }
  }

  private void ShowImage(string selfie, string passwordImage, string idFront, string idBack, string registerDate, string membershipNo) {
   selfieDisplay.ImageUrl = "/Remit/GetFileView.ashx?registerDate=" + registerDate + "&membershipNo=" + membershipNo + "&fileName=" + selfie;
   passDisplay.ImageUrl = "/Remit/GetFileView.ashx?registerDate=" + registerDate + "&membershipNo=" + membershipNo + "&fileName=" + passwordImage;
   frontIdDisplay.ImageUrl = "/Remit/GetFileView.ashx?registerDate=" + registerDate + "&membershipNo=" + membershipNo + "&fileName=" + idFront;
   backIdDisplay.ImageUrl = "/Remit/GetFileView.ashx?registerDate=" + registerDate + "&membershipNo=" + membershipNo + "&fileName=" + idBack;
  }

  private void PopulateDdl() {
   _sl.SetDDL(ref genderList, "EXEC proc_online_dropDownList @flag='GenderList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
   _sl.SetDDL(ref countryList, "EXEC proc_online_dropDownList @flag='onlineCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "");
   _sl.SetDDL(ref nativeCountry, "EXEC proc_online_dropDownList @flag='allCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "142", "");
   _sl.SetDDL(ref occupation, "EXEC proc_online_dropDownList @flag='occupationList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
   _sl.SetDDL(ref idType, "EXEC proc_online_dropDownList @flag='IdTypeWithDetails',@user='" + GetStatic.GetUser() + "',@countryId='" + nativeCountry.SelectedValue + "'", "valueId", "detailTitle", "8008|National ID|N", "");
   _sl.SetDDL(ref ddSourceOfFound, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3900", "valueId", "detailTitle", "", "Select..");
   _sl.SetDDL(ref ddlVisaStatus, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=7005", "valueId", "detailTitle", "", "Select..");
   _sl.SetDDL(ref district, "EXEC proc_online_dropDownList @flag='province',@countryId='" + nativeCountry.SelectedValue + "'", "id", "PROVINCE_NAME", "", "Select..");
   _sdd.SetDDL(ref ddlCity, "EXEC proc_online_dropDownList @flag='city',@provinceId=" + _sdd.FilterString(district.SelectedValue), "id", "CITY_NAME", "", "Select..");
   _sl.SetDDL(ref bankName, "EXEC proc_online_dropDownList @flag='bank',@user='" + GetStatic.GetUser() + "'", "id", "BankName", "select", "Select..");
   _sl.SetDDL(ref occupType, "EXEC proc_online_dropDownList @flag='occupationListnew',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
  }

  protected void register_Click(object sender, EventArgs e) {
   string eId = GetStatic.ReadQueryString("customerId", "");

   if(eId == "") {
    if(!_sl.HasRight(AddFunctionId)) {
     GetStatic.AlertMessage(this, "You are not authorized to Add Customer!");
     return;
    }
   } else {
    if(!_sl.HasRight(EditFunctionId)) {
     GetStatic.AlertMessage(this, "You are not authorized to Edit Customer!");
     return;
    }
   }

   if(hddTxnsMade.Value == "Y" && (!email.Text.Equals(hddOldEmailValue.Value.ToString()))) {
    GetStatic.AlertMessage(this, "You can not change the email of customer who have already done transaction!");
    return;
   }
   string trimmedfirstName = firstName.Text.Trim() == "" ? null : firstName.Text.Trim();
   var cityValue = Request.Form["ddlCity"];

   if(!string.IsNullOrWhiteSpace(ddlCity.SelectedValue)) {
    cityValue = ddlCity.SelectedValue;
   }

   if(string.IsNullOrWhiteSpace(cityValue)) {
    cityValue = Request.Form["ctl00$ContentPlaceHolder1$ddlCity"];
   }

   string trimmedlastName = lastName.Text.Trim() == "" ? null : lastName.Text.Trim();
   string nonMonPepStr = "0";
   if(nonMonPep.Checked == true) {
    nonMonPepStr = "1";
   }
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
    occupType = occupType.SelectedValue,
    isOrg = isOrg.SelectedValue,
    userName = username.Text,
    nonMonPep = nonMonPepStr
   };

   if(hdnCustomerId.Value != "") {
    customerModel.customerId = hdnCustomerId.Value;
    customerModel.flag = "customer-editeddata";
   }
   var obj = JsonConvert.SerializeObject(customerModel);
   var dbResult = _cd.RegisterCustomerNew(customerModel);
   if(dbResult.ErrorCode == "0") {
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
   if(dbResult.ErrorCode == "0") {
    GetStatic.AlertMessage(this, dbResult.Msg);
    //if (!string.IsNullOrWhiteSpace(hdnCustomerId.Value))
    //{
    if(GetCallFrom().ToString().ToLower() == "approvecustomer") {
     Response.Redirect("/Remit/Administration/OnlineCustomer/List.aspx");
    } else {
     Response.Redirect("List.aspx");
    }
    return;
   } else {
    GetStatic.AlertMessage(this, dbResult.Msg);
    return;
   }
  }

  public string UploadImage(FileUpload doc, string registerDate, string membershipId, string customerId, string idTypeName) {
   try {
    string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
    string DocumentExtension = GetStatic.ReadWebConfig("customerDocFileExtension", "");
    string rootPath = GetStatic.GetCustomerFilePath();
    string folderPath = Path.Combine(rootPath, "CustomerDocument", registerDate.Replace("-", "\\"), membershipId);
    if(!Directory.Exists(folderPath))
     Directory.CreateDirectory(folderPath);
    string fileName = customerId + "_" + idTypeName + fileExtension;
    string filePath = Path.Combine(folderPath, fileName);
    doc.SaveAs(filePath);
    return fileName;
   } catch(Exception) {
    return "";
   }
  }

  public static string GetCallFrom() {
   return GetStatic.ReadQueryString("callFrom", "");
  }

  private void PopulateCity() {
   string provinceId = Request.Form["provinceId"];
   var dt = _cd.GetCity(provinceId);
   Response.ContentType = "text/plain";
   var json = DataTableToJson(dt);
   Response.Write(json);
   Response.End();
  }

  private void PopulateProvince() {
   string nativeId = Request.Form["nativeId"];
   var dt = _cd.GetProvince(nativeId);
   Response.ContentType = "text/plain";
   var json = DataTableToJson(dt);
   Response.Write(json);
   Response.End();
  }

  private void PopulateIdType() {
   string nativeId = Request.Form["nativeId"];
   var dt = _cd.GetIdType(nativeId, GetStatic.GetUser());
   Response.ContentType = "text/plain";
   var json = DataTableToJson(dt);
   Response.Write(json);
   Response.End();
  }

  public static string DataTableToJson(DataTable table) {
   if(table == null)
    return "";
   var list = new List<Dictionary<string, object>>();

   foreach(DataRow row in table.Rows) {
    var dict = new Dictionary<string, object>();

    foreach(DataColumn col in table.Columns) {
     dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
    }
    list.Add(dict);
   }
   var serializer = new JavaScriptSerializer();
   string json = serializer.Serialize(list);
   return json;
  }

  public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
   return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
  }
 }
}