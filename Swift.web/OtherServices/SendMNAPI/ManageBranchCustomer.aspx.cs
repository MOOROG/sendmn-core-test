using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI
{
  public partial class NewBranchCustomer : System.Web.UI.Page {
    private const string ViewFunctionId = "20111300";
    private const string AddFunctionId = "20230206";
    private const string EditFunctionId = "20111320";
    private const string ViewDocFunctionId = "20111330";
    private const string UploadDocFunctionId = "20111340";
    private const string ViewKYCFunctionId = "20111350";
    private const string UpdateKYCFunctionId = "20111360";
    private const string ViewBenificiaryFunctionId = "20111370";
    private const string AddBenificiaryFunctionId = "20111380";
    private const string EditBenificiaryFunctionId = "20111390";

    private const string ViewFunctionIdAgent = "40120000";
    private const string AddFunctionIdAgent = "40120010";
    private const string EditFunctionIdAgent = "40120020";
    private const string ViewDocFunctionIdAgent = "40120030";
    private const string UploadDocFunctionIdAgent = "40120040";
    private const string ViewKYCFunctionIdAgent = "40120050";
    private const string UpdateKYCFunctionIdAgent = "40120060";
    private const string ViewBenificiaryFunctionIdAgent = "40120070";
    private const string AddBenificiaryFunctionIdAgent = "40120080";
    private const string EditBenificiaryFunctionIdAgent = "40120090";

    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly RemittanceDao obj = new RemittanceDao();

    public string docPath;
    public List<string> photoPreview = new List<string> { "", "", "", "", "" };

    protected long GetId() {
      return GetStatic.ReadNumericDataFromQueryString("customerId");
    }

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();

        string sql = "SELECT * FROM commonCode";
        DataSet ds = obj.ExecuteDataset(sql);
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          foreach (DataRow row in ds.Tables[0].Rows) {
            ListItem listItem = new ListItem();
            listItem.Value = row["code"].ToString();
            listItem.Text = row["message"].ToString();
            occupationType.Items.Add(listItem);
          }
        }
        sql = "exec proc_online_dropDownList @Flag = 'allCountrylist'";
        ds = obj.ExecuteDataset(sql);
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          foreach (DataRow row in ds.Tables[0].Rows) {
            ListItem listItem = new ListItem();
            listItem.Value = row["countryId"].ToString();
            listItem.Text = row["countryName"].ToString();
            nationalityDdl.Items.Add(listItem);
          }
        }

        if (GetId() > 0)
          PopulateDataById();
      }
      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    private void PopulateDataById() {
      string sql = "SELECT TOP(1) * FROM branchCustomer WHERE customerId = " + obj.FilterString(GetId().ToString());
      DataRow dr = obj.ExecuteDataRow(sql);

      if (dr != null) {
        regNum.Text = dr["rd"].ToString();
        lastname.Text = dr["ovog"].ToString();
        firstname.Text = dr["ner"].ToString();
        gender.SelectedValue = dr["huis"].ToString().Trim();
        addressProvince.Text = dr["aimag"].ToString();
        addressDistrict.Text = dr["sum"].ToString();
        address.Text = dr["hayag"].ToString();
        email.Text = dr["email"].ToString();
        mobileNum.Text = dr["phones"].ToString();
        dateofbirth.Text = dr["birthday"].ToString().Replace("/", "-");
        occupationType.SelectedValue = dr["occupType"].ToString();
        if (dr["nationality"] != null)
          nationalityDdl.SelectedValue = dr["nationality"].ToString();

        photoPreview[0] = "<p>" + (dr["photo1"].ToString() != "" ? "<img class='img-responsive' src='" + docPath + "/customerIds/" + dr["photo1"].ToString() + "'/>" + dr["photo1"].ToString() : "empty") + "</p>";
        photoPreview[1] = "<p>" + (dr["photo2"].ToString() != "" ? "<img class='img-responsive' src='" + docPath + "/customerIds/" + dr["photo2"].ToString() + "'/>" + dr["photo2"].ToString() : "empty") + "</p>";
        photoPreview[2] = "<p>" + (dr["photo3"].ToString() != "" ? "<img class='img-responsive' src='" + docPath + "/customerIds/" + dr["photo3"].ToString() + "'/>" + dr["photo3"].ToString() : "empty") + "</p>";
        photoPreview[3] = "<p>" + (dr["photo4"].ToString() != "" ? "<img class='img-responsive' src='" + docPath + "/customerIds/" + dr["photo4"].ToString() + "'/>" + dr["photo4"].ToString() : "empty") + "</p>";
        photoPreview[4] = "<p>" + (dr["photo5"].ToString() != "" ? "<img class='img-responsive' src='" + docPath + "/customerIds/" + dr["photo5"].ToString() + "'/>" + dr["photo5"].ToString() : "empty") + "</p>";

        btnRegister.Text = "Save Customer";
      }
    }

    protected void btnRegister_Click(object sender, EventArgs e) {
      string custFirstName = firstname.Text;
      string custLastName = lastname.Text;
      string custRegNum = regNum.Text;
      string custMobileNum = mobileNum.Text;
      string custEmail = email.Text;
      string custGender = gender.SelectedValue;
      string custProvince = addressProvince.SelectedValue;
      string custDistrict = addressDistrict.Text;
      string custAddress = address.Text;
      string custDob = dateofbirth.Text.Replace("-", "/");
      string custOccupType = occupationType.SelectedValue;
      string nationality = nationalityDdl.SelectedValue;

      string custPhoto1 = photo1.FileName != "" ? UploadImage(photo1, custRegNum, "1") : "";
      string custPhoto2 = photo2.FileName != "" ? UploadImage(photo2, custRegNum, "2") : "";
      string custPhoto3 = photo3.FileName != "" ? UploadImage(photo3, custRegNum, "3") : "";
      string custPhoto4 = photo4.FileName != "" ? UploadImage(photo4, custRegNum, "4") : "";
      string custPhoto5 = photo5.FileName != "" ? UploadImage(photo5, custRegNum, "5") : "";

      string sql = "";
      if (GetId() > 0) {
        sql = "UPDATE branchCustomer SET "
        + "rd=" + (custRegNum != "" ? "N" : "") + obj.FilterString(custRegNum) + ","
        + "ovog=" + (custLastName != "" ? "N" : "") + obj.FilterString(custLastName) + ","
        + "ner=" + (custFirstName != "" ? "N" : "") + obj.FilterString(custFirstName) + ","
        + "huis=" + (custGender != "" ? "N" : "") + obj.FilterString(custGender) + ","
        + "aimag=" + (custProvince != "" ? "N" : "") + obj.FilterString(custProvince) + ","
        + "sum=" + (custDistrict != "" ? "N" : "") + obj.FilterString(custDistrict) + ","
        + "hayag=" + (custAddress != "" ? "N" : "") + obj.FilterString(custAddress) + ","
        + "email=" + obj.FilterString(custEmail) + ","
        + "birthday=" + obj.FilterString(custDob) + ","
        + "phones=" + obj.FilterString(custMobileNum) + ","
        + (custPhoto1 != "" ? "photo1=N" + obj.FilterString(custPhoto1) + "," : "")
        + (custPhoto2 != "" ? "photo2=N" + obj.FilterString(custPhoto2) + "," : "")
        + (custPhoto3 != "" ? "photo3=N" + obj.FilterString(custPhoto3) + "," : "")
        + (custPhoto4 != "" ? "photo4=N" + obj.FilterString(custPhoto4) + "," : "")
        + (custPhoto5 != "" ? "photo5=N" + obj.FilterString(custPhoto5) + "," : "")
        + "occupType=" + obj.FilterString(custOccupType) + ","
        + "nationality=" + obj.FilterString(nationality)
        + " WHERE customerId = " + obj.FilterString(GetId().ToString());
        obj.ExecuteDataset(sql);
      } else {
        var sql1 = "Select rd from branchCustomer where rd = N'" + custRegNum + "'";
        string retVal = obj.GetSingleResult(sql1);
        if (string.IsNullOrEmpty(retVal)) {
          sql = "INSERT INTO branchCustomer (rd, ovog, ner, huis, aimag, sum, hayag, email, birthday, phones, photo1, photo2, photo3, photo4, photo5, occupType,nationality) VALUES ("
               + (custRegNum != "" ? "N" : "") + obj.FilterString(custRegNum) + ","
               + (custLastName != "" ? "N" : "") + obj.FilterString(custLastName) + ","
               + (custFirstName != "" ? "N" : "") + obj.FilterString(custFirstName) + ","
               + (custGender != "" ? "N" : "") + obj.FilterString(custGender) + ","
               + (custProvince != "" ? "N" : "") + obj.FilterString(custProvince) + ","
               + (custDistrict != "" ? "N" : "") + obj.FilterString(custDistrict) + ","
               + (custAddress != "" ? "N" : "") + obj.FilterString(custAddress) + ","
               + obj.FilterString(custEmail) + ","
               + obj.FilterString(custDob) + ","
               + obj.FilterString(custMobileNum) + ","
               + (custPhoto1 != "" ? "N" : "") + obj.FilterString(custPhoto1) + ","
               + (custPhoto2 != "" ? "N" : "") + obj.FilterString(custPhoto2) + ","
               + (custPhoto3 != "" ? "N" : "") + obj.FilterString(custPhoto3) + ","
               + (custPhoto4 != "" ? "N" : "") + obj.FilterString(custPhoto4) + ","
               + (custPhoto5 != "" ? "N" : "") + obj.FilterString(custPhoto5) + ","
               + obj.FilterString(custOccupType) + ","
               + obj.FilterString(nationality) + ")";
          obj.ExecuteDataset(sql);
        } 
      }

      Response.Redirect("BranchCustomer.aspx");
      return;
    }

    public string UploadImage(FileUpload doc, string regNum, string photoId) {
      try {
        string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
        string folderPath = GetStatic.ReadWebConfig("customerIdsDocPath", "E:\\customerIds");
        if (!Directory.Exists(folderPath))
          Directory.CreateDirectory(folderPath);
        string fileName = regNum + "-" + photoId + fileExtension;
        string filePath = Path.Combine(folderPath, fileName);
        if (File.Exists(filePath)) {
          File.Delete(filePath);
        }
        doc.SaveAs(filePath);
        return fileName;
      } catch (Exception) {
        return "";
      }
    }
  }
}