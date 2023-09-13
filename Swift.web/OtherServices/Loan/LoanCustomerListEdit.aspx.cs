using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Text;
using System.IO;
using System.Windows.Forms;

namespace Swift.web.OtherServices.Loan { 
  public partial class LoanCustomerListEdit : System.Web.UI.Page {

    private const string AddFunctionIdAgent = "40120010";
    private const string AddFunctionId = "20111310";

    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly RemittanceDao obj = new RemittanceDao();

    string rwId = "";

    public string docPath;

    public List<string> filePreview = new List<string> { "", "", "", "", "", "", "", "", "", "" };

    public string loanNumber;

    protected void Page_Load(object sender, EventArgs e) {

      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
      rwId = GetStatic.ReadQueryString("loanId", "");
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
        PopulateDdl();
        if (!rwId.Equals(""))
          PopulateDataById();
          
      }
    }

    // Creates Loan Time from 6 months increases by 6 to 96
    private void PopulateDdl() {
      for (int ii = 6; ii < 97; ii += 6) {
        ListItem listItem = new ListItem();
        listItem.Value = ii.ToString();
        listItem.Text = ii + " month";
        loanTime.Items.Add(listItem);
      } 

      string sql = "select stateId code, stateName name FROM loanState where isActive = '1' and isDeleted = '0' and stateId > 2";
      DataSet ds = obj.ExecuteDataset(sql);
      if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
        foreach (DataRow row in ds.Tables[0].Rows) {
          ListItem listItem = new ListItem();
          listItem.Value = row["code"].ToString();
          listItem.Text = row["name"].ToString();
          stateName.Items.Add(listItem);
        }
      }
    }
    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(AddFunctionIdAgent, AddFunctionId));
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    // Populating old/current data from DB.
    private void PopulateDataById() {

      string sql = "EXEC [proc_loanDataList] @flg = 'edit', @loanNumber = " + obj.FilterString(rwId);
      DataRow dr = obj.ExecuteDataRow(sql);

      loanNumber = dr["loanNumber"].ToString();

      if (dr != null) {
        
        loanAmount.Text = dr["loanAmount"].ToString();
        loanTime.SelectedValue = dr["loanTime"].ToString();
        interestRate.Text = dr["interestRate"].ToString();
        if (dr["createdDate"] != DBNull.Value)
          createdDate.Text = DateTime.Parse(dr["createdDate"].ToString()).ToString("yyyy-MM-dd");
        if (dr["extendedDate"] != DBNull.Value)
          extendedDate.Text = DateTime.Parse(dr["extendedDate"].ToString()).ToString("yyyy-MM-dd");
        stateName.SelectedValue = dr["stateId"].ToString();
        if (dr["lnDescription"] != DBNull.Value)   
          lnDescription.Text = dr["lnDescription"].ToString();

        if (!string.IsNullOrEmpty(dr["file1"].ToString()))
          filePreview[0] = "<p><a href='" + docPath + "/allIDS/" + dr["file1"].ToString() + "' class='ahref'>" + dr["file1"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file1"] + "@file1'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file2"].ToString()))
          filePreview[1] = "<p><a href='" + docPath + "/allIDS/" + dr["file2"].ToString() + "' class='ahref'>" + dr["file2"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file2"] + "@file2'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file3"].ToString()))
          filePreview[2] = "<p><a href='" + docPath + "/allIDS/" + dr["file3"].ToString() + "' class='ahref'>" + dr["file3"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file3"] + "@file3'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file4"].ToString()))
          filePreview[3] = "<p><a href='" + docPath + "/allIDS/" + dr["file4"].ToString() + "' class='ahref'>" + dr["file4"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file4"] + "@file4'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file5"].ToString()))
          filePreview[4] = "<p><a href='" + docPath + "/allIDS/" + dr["file5"].ToString() + "' class='ahref'>" + dr["file5"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file5"] + "@file5'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file6"].ToString()))
          filePreview[5] = "<p><a href='" + docPath + "/allIDS/" + dr["file6"].ToString() + "' class='ahref'>" + dr["file6"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file6"] + "@file6'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file7"].ToString()))
          filePreview[6] = "<p><a href='" + docPath + "/allIDS/" + dr["file7"].ToString() + "' class='ahref'>" + dr["file7"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file7"] + "@file7'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file8"].ToString()))
          filePreview[7] = "<p><a href='" + docPath + "/allIDS/" + dr["file8"].ToString() + "' class='ahref'>" + dr["file8"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file8"] + "@file8'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file9"].ToString()))
          filePreview[8] = "<p><a href='" + docPath + "/allIDS/" + dr["file9"].ToString() + "' class='ahref'>" + dr["file9"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file9"] + "@file9'><i class='fa fa-close'></i></button></p>";
        if (!string.IsNullOrEmpty(dr["file10"].ToString()))
          filePreview[9] = "<p><a href='" + docPath + "/allIDS/" + dr["file10"].ToString() + "' class='ahref'>" + dr["file10"].ToString() + "</a><button class='DeleteBtn' onclick='return delFunction(this)' data-fname = '" + dr["fileId"] + '@' + docPath + "/allIDS/" + dr["file10"] + "@file10'><i class='fa fa-close'></i></button></p>";
        btnEdit.Text = "Save Loan";
        btnCancel.Text = "Cancel";
      }
    }

    // Saving/updating new data to DB
    protected void btnEdit_Click(object sender, EventArgs e) {

      string lnFile1 = file1.FileName != "" ? UploadFile(file1) : "";
      string lnFile2 = file2.FileName != "" ? UploadFile(file2) : "";
      string lnFile3 = file3.FileName != "" ? UploadFile(file3) : "";
      string lnFile4 = file4.FileName != "" ? UploadFile(file4) : "";
      string lnFile5 = file5.FileName != "" ? UploadFile(file5) : "";
      string lnFile6 = file6.FileName != "" ? UploadFile(file6) : "";
      string lnFile7 = file7.FileName != "" ? UploadFile(file7) : "";
      string lnFile8 = file8.FileName != "" ? UploadFile(file8) : "";
      string lnFile9 = file9.FileName != "" ? UploadFile(file9) : "";
      string lnFile10 = file10.FileName != "" ? UploadFile(file10) : "";
      string sql = "EXEC [proc_loanDataList] @flg = 'update', @loanNumber = " + obj.FilterString(rwId);
      sql += ", @loanAmount = " + obj.FilterString(loanAmount.Text);
      sql += ", @loanTime =" + obj.FilterString(loanTime.SelectedValue);
      sql += ", @interestRate =" + obj.FilterString(interestRate.Text);
      sql += ", @createdDate =" + obj.FilterString(createdDate.Text);
      sql += ", @extendedDate =" + obj.FilterString(extendedDate.Text);
      sql += ", @stateName =" + obj.FilterString(stateName.SelectedValue);
      sql += ", @lnDescription =" + obj.FilterString(lnDescription.Text);
      if (!string.IsNullOrEmpty(lnFile1)) {
        sql += ", @file1 = N" + obj.FilterString(lnFile1);
      }
      if (!string.IsNullOrEmpty(lnFile2)) {
        sql += ", @file2 = N" + obj.FilterString(lnFile2);
      }
      if (!string.IsNullOrEmpty(lnFile3)) {
        sql += ", @file3 = N" + obj.FilterString(lnFile3);
      }
      if (!string.IsNullOrEmpty(lnFile4)) {
        sql += ", @file4 = N" + obj.FilterString(lnFile4);
      }
      if (!string.IsNullOrEmpty(lnFile5)) {
        sql += ", @file5 = N" + obj.FilterString(lnFile5);
      }
      if (!string.IsNullOrEmpty(lnFile6)) {
        sql += ", @file6 = N" + obj.FilterString(lnFile6);
      }
      if (!string.IsNullOrEmpty(lnFile7)) {
        sql += ", @file7 = N" + obj.FilterString(lnFile7);
      }
      if (!string.IsNullOrEmpty(lnFile8)) {
        sql += ", @file8 = N" + obj.FilterString(lnFile8);
      }
      if (!string.IsNullOrEmpty(lnFile9)) {
        sql += ", @file9 = N" + obj.FilterString(lnFile9);
      }
      if (!string.IsNullOrEmpty(lnFile10)) {
        sql += ", @file10 = N" + obj.FilterString(lnFile10);
      }
      sql += ", @user = " + obj.FilterString(GetStatic.GetUser());

      obj.ExecuteDataset(sql);
      Response.Redirect("LoanCustomerList.aspx");

      return;
    }

    protected void btnCancel_Click(object sender, EventArgs e) {

      Response.Redirect("LoanCustomerList.aspx");

      return;
    }

    public string UploadFile(FileUpload doc) {
      string filePrefix = UniqueNumber();
      try {
        string fileExtension = new FileInfo(doc.PostedFile.FileName).Extension;
        string folderPath = GetStatic.ReadWebConfig("allIDS", "D:\\allIDS");
        if (!Directory.Exists(folderPath))
          Directory.CreateDirectory(folderPath);
        string fileName = filePrefix + "_" + doc.PostedFile.FileName;
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

    public static List<DateTime> GetDates(int year, int month) {
      return Enumerable.Range(1, DateTime.DaysInMonth(year, month))
                       .Select(day => new DateTime(year, month, day))
                       .ToList();
    }

    private string UniqueNumber() {
      DateTime _now = DateTime.Now;
      string _dd = _now.ToString("dd"); //
      string _mm = _now.ToString("MM");
      string _yy = _now.ToString("yyyy");
      string _hh = _now.Hour.ToString();
      string _min = _now.Minute.ToString();
      string _ss = _now.Second.ToString();

      string _uniqueId = _dd + _hh + _mm + _min + _ss + _yy;
      return _uniqueId;
    }

  }
}