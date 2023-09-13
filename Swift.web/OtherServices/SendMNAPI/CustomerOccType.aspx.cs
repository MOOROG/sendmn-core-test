using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.OtherServices.SendMNAPI {
  public partial class CustomerOccType : Page {
    private const string ViewFunctionId = "20111300";
    private const string ViewFunctionIdAgent = "40120000";

    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    RemittanceDao rDao = new RemittanceDao();
    string custId;
    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();
        string sql = "select code, message from commonCode where code like 'OC%'";

        DataTable ds = rDao.ExecuteDataTable(sql);
        occType.DataSource = ds;
        occType.DataTextField = "message";
        occType.DataValueField = "code";
        occType.DataBind();
      }
      custId = GetStatic.ReadQueryString("customerId", "");
    }
    private void Authenticate() {
      swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
    }
    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    protected void submitBtn_Click(object sender, EventArgs e) {
      string mine = occType.SelectedValue;
      string sql = "update branchCustomer set occupType = '" + mine + "' where customerId = " + custId;
      DataTable ds = rDao.ExecuteDataTable(sql);
      this.ClientScript.RegisterClientScriptBlock(this.GetType(), "Close", "window.close()", true);
    }
  }
}