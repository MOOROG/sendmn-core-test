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

namespace Swift.web.OtherServices.Loan {
  public partial class NewLoanState : System.Web.UI.Page {
    private const string ViewFunctionId = "20111300";
    private const string AddFunctionId = "20111310";
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

    protected long GetId() {
      return GetStatic.ReadNumericDataFromQueryString("stateId");
    }

    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();

        if (GetId() > 0) {
          PopulateDataById();
        } else {
          stateNmBx.Visible = true;
          stateName.Visible = false;
        }
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

      stateName.Items.Clear();
      string sql = "select stateId code, stateName name FROM loanState where isActive = '1' and isDeleted = '0'";
      DataSet ds = obj.ExecuteDataset(sql);
      if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
        foreach (DataRow row in ds.Tables[0].Rows) {
          ListItem listItem = new ListItem();
          listItem.Value = row["code"].ToString();
          listItem.Text = row["name"].ToString();
          stateName.Items.Add(listItem);
        }
      }

      sql = "SELECT * FROM loanState WHERE stateID = " + obj.FilterString(GetId().ToString());
      DataRow dr = obj.ExecuteDataRow(sql);

      if (dr != null) {
        stateName.SelectedValue = dr["stateId"].ToString();
        isActive.SelectedValue = dr["isActive"].ToString();
        isDeleted.SelectedValue = dr["isDeleted"].ToString();
        btnRegister.Text = "Save Loan State"; 
      }
    }

    protected void btnRegister_Click(object sender, EventArgs e) {

      string loanStateName = stateName.SelectedValue;
      string loanIsActive = isActive.SelectedValue;
      string loanIsDeleted = isDeleted.SelectedValue;

      if (GetId() > 0) {
        
        string sql = "";
        sql = "EXEC [proc_loanState] @flg = 'update', @stateID = " + obj.FilterString(GetId().ToString());
        //sql += ", @stateName = " + obj.FilterString(loanStateName);
        sql += ", @isActive =" + obj.FilterString(loanIsActive);
        sql += ", @isDeleted =" + obj.FilterString(loanIsDeleted);
        obj.ExecuteDataset(sql);

      } else {
        var sql1 = "Select stateName from loanState where stateName = N" + obj.FilterString(stateNmBx.Text);
        string retVal = obj.GetSingleResult(sql1);
        if (string.IsNullOrEmpty(retVal)) {
          string sql = "INSERT INTO loanState (stateName, isActive, isDeleted) VALUES ("
               + (stateNmBx.Text != "" ? "N" : "") + obj.FilterString(stateNmBx.Text) + ","
               + (loanIsActive != "" ? "N" : "") + obj.FilterString(loanIsActive) + ","
               + (loanIsDeleted != "" ? "N" : "") + obj.FilterString(loanIsDeleted) + ")";
          obj.ExecuteDataset(sql);
        } else {
          GetStatic.AlertMessage(this, "StateName already exists!");
          return;
        }
      }
      Response.Redirect("loanState.aspx");
      return;
    }
  }
}