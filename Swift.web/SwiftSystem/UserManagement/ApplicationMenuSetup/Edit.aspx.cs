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

namespace Swift.web.SwiftSystem.UserManagement.ApplicationMenuSetup {
  public partial class Edit : System.Web.UI.Page {
    private const string ViewFunctionId = "10232901";

    private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
    private readonly RemittanceDao obj = new RemittanceDao();

    protected long GetId() {
      return GetStatic.ReadNumericDataFromQueryString("functionId");
    }

    protected void Page_Load(object sender, EventArgs e) {
      if(!IsPostBack) {
        GetStatic.PrintMessage(Page);
        Authenticate();

        string sql = "select distinct menuGroup from applicationMenus where menuGroup != ''";
        DataSet ds = obj.ExecuteDataset(sql);
        if(ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          foreach(DataRow row in ds.Tables[0].Rows) {
            ListItem listItem = new ListItem();
            listItem.Value = row["menuGroup"].ToString();
            listItem.Text = row["menuGroup"].ToString();
            menuGroup.Items.Add(listItem);
          }
        }
        sql = "exec proc_online_dropDownList @Flag = 'menuModule'";
        ds = obj.ExecuteDataset(sql);
        if(ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0) {
          foreach(DataRow row in ds.Tables[0].Rows) {
            ListItem listItem = new ListItem();
            listItem.Value = row["Value"].ToString();
            listItem.Text = row["text"].ToString();
            module.Items.Add(listItem);
          }
        }

        if(GetId() > 0)
          PopulateDataById();
      }
    }

    private void Authenticate() {
      swiftLibrary.CheckAuthentication(ViewFunctionId);
    }

    public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin) {
      return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
    }

    private void PopulateDataById() {
      string sql = "SELECT TOP(1) * FROM applicationMenus WHERE functionId = " + obj.FilterString(GetId().ToString());
      DataRow dr = obj.ExecuteDataRow(sql);

      if(dr != null) {
        functionId.Text = dr["functionId"].ToString();
        menuName.Text = dr["menuName"].ToString();
        menuDesc.Text = dr["menuDescription"].ToString();
        module.SelectedValue = dr["Module"].ToString().Trim();
        link.Text = dr["linkPage"].ToString();
        agentGroup.Text = dr["AgentMenuGroup"].ToString();
        menuGroup.SelectedValue = dr["menuGroup"].ToString();
        btnRegister.Text = "Save Menu";
      }
    }

    protected void btnRegister_Click(object sender, EventArgs e) {
      string moduleId = module.SelectedValue;
      string menuGroupName = menuGroup.SelectedValue;
      string menu = menuName.Text;
      string linkPage = link.Text;
      string agentMenuGroup = agentGroup.Text;

      string sql = "";
      if(GetId() > 0) {
        sql = "UPDATE applicationMenus SET "
        + "module=" + obj.FilterString(moduleId) + ","
        + "menuGroup=" + obj.FilterString(menuGroupName) + ","
        + "menuName=" + obj.FilterString(menu) + ","
        + "linkPage=" + obj.FilterString(linkPage) + ","
        + "AgentMenuGroup=" + obj.FilterString(agentMenuGroup) + ","
        + "modifiedDate=GETDATE(),"
        + "modifiedBy=" + obj.FilterString(GetStatic.GetUser()) + ""
        + " WHERE functionId = " + obj.FilterString(GetId().ToString());
        obj.ExecuteDataset(sql);
      } else {
        sql = "select top 1 functionId from applicationMenus where module = '" + moduleId + "' and functionId LIKE '" + moduleId + "%' order by functionId desc";
        string retVal = obj.GetSingleResult(sql);
        decimal a = Convert.ToDecimal(retVal.Substring(4, 2)) + 1;
        string function = moduleId + "23" + a + "00";
        sql = "INSERT INTO applicationMenus (module, functionId, menuName, menuDescription, linkPage, menuGroup, isActive,AgentMenuGroup,createdBy,createdDate) VALUES ("
             + obj.FilterString(moduleId) + ","
             + obj.FilterString(function) + ","
             + obj.FilterString(menu) + ","
             + obj.FilterString("Menu for: " + menu) + ","
             + obj.FilterString(linkPage) + ","
             + obj.FilterString(menuGroupName) + ","
             + obj.FilterString("Y") + ","
             + obj.FilterString(agentMenuGroup) + ","
             + obj.FilterString(GetStatic.GetUser()) + ","
             + "GETDATE()" + ")";
        obj.ExecuteDataset(sql);
        sql = "INSERT INTO applicationFunctions (parentFunctionId, functionId, functionName,createdBy,createdDate) VALUES ("
             + obj.FilterString(function) + ","
             + obj.FilterString(function) + ","
             + obj.FilterString("View") + ","
             + obj.FilterString(GetStatic.GetUser()) + ","
             + "GETDATE()" + ")";
        obj.ExecuteDataset(sql);
      }

      Response.Redirect("List.aspx");
      return;
    }
  }
}