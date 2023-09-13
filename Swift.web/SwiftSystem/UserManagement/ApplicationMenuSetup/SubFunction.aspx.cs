using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI.WebControls;

namespace Swift.web.SwiftSystem.UserManagement.ApplicationMenuSetup {
  public partial class SubFunction : System.Web.UI.Page {
    private const string ViewFunctionId = "10232903";

    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly RemittanceDao obj = new RemittanceDao();

    public string docPath;
    public List<string> photoPreview = new List<string> { "", "", "", "", "" };

    protected long GetId() {
      return GetStatic.ReadNumericDataFromQueryString("functionId");
    }
    protected long GetParentId() {
      return GetStatic.ReadNumericDataFromQueryString("parentId");
    }
    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
        parentId.Text = GetParentId().ToString();
        if(GetId() > 0)
          PopulateDataById();
      }
      docPath = Request.Url.GetLeftPart(UriPartial.Authority);
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    private void PopulateDataById() {
      string sql = "SELECT TOP(1) * FROM applicationFunctions WHERE functionId = " + obj.FilterString(GetId().ToString());
      DataRow dr = obj.ExecuteDataRow(sql);

      if(dr != null) {
        functionName.Text = dr["functionName"].ToString();
        parentId.Text = dr["parentFunctionId"].ToString();
        functionId.Text = dr["functionId"].ToString();
        btnRegister.Text = "Save Menu";
      }
    }

    protected void btnRegister_Click(object sender, EventArgs e) {
      string name = functionName.Text;
      string function = "";
      string sql = "";
      if(GetId() > 0) {
        sql = "UPDATE applicationFunctions SET "
        + "functionName=" + obj.FilterString(name) + ","
        + "modifiedDate=GETDATE(),"
        + "modifiedBy=" + obj.FilterString(GetStatic.GetUser()) + ""
        + " WHERE functionId = " + obj.FilterString(GetId().ToString());
        obj.ExecuteDataset(sql);
      } else {
        sql = "select top 1 functionId from applicationFunctions where parentFunctionId = '" + GetParentId() + "' order by functionId desc";
        function = obj.GetSingleResult(sql);
        decimal a = Convert.ToDecimal(function.Substring(0, 8)) + 1;
        function = a.ToString("00000000");
        sql = "INSERT INTO applicationFunctions (parentFunctionId, functionId, functionName,createdBy,createdDate) VALUES ("
             + obj.FilterString(GetParentId().ToString()) + ","
             + obj.FilterString(function) + ","
             + obj.FilterString(name) + ","
             + obj.FilterString(GetStatic.GetUser()) + ","
             + "GETDATE()" + ")";
        obj.ExecuteDataset(sql);
      }
      Response.Redirect("FunctionDetail.aspx?parentId=" + GetParentId());
      return;
    }
  }
}