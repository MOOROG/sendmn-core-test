using Swift.DAL.AccountReport;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.Model;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI.WebControls;
using System.Xml;

namespace Swift.web.AgentNew.Modify {
  public partial class AgentFund : System.Web.UI.Page
   {
      private AccountStatementDAO st = new AccountStatementDAO();
      private const string ViewFunctionId = "40101700";
      private const string ReversalId = "20101110";
      private SwiftLibrary _sl = new SwiftLibrary();

      protected void Page_Load(object sender, EventArgs e)
      {
         //check session
         _sl.CheckSession();
         var methodName = GetStatic.ReadFormData("MethodName", "");
         if (methodName.Equals("ViewStatement"))
            GetStatementData();

         if (!IsPostBack)
         {
            startDate.Text = System.DateTime.Today.ToString("yyyy-MM-dd");
            startDate2.Text = System.DateTime.Today.ToString("yyyy-MM-dd");
            endDate.Text = System.DateTime.Today.ToString("yyyy-MM-dd");
            endDate2.Text = System.DateTime.Today.ToString("yyyy-MM-dd");
            Authenticate();
         }
         PopulateDDL();
      }
      private void GetStatementData()
      {
         string fromDate = Request.Form["FromDate"];
         string toDate = Request.Form["ToDate"];
         string accNum = Request.Form["accNum"];
         string accName = Request.Form["accName"];
         string accCurr = Request.Form["accCurr"];
         string type = Request.Form["type"];
         bool hasRightReverse = _sl.HasRight(ReversalId);

         List<StatementModel> result = st.GetACStatementNewAjax(accNum, fromDate, toDate, accCurr, type, hasRightReverse);
         GetStatic.JsonResponse(result, this);
      }

      private void PopulateDDL()
      {
         RemittanceLibrary r = new RemittanceLibrary();
         r.SetDDL(ref ddlCurrency, "EXEC Proc_dropdown_remit @FLAG='Currency'", "val", "Name", "", "Select FCY");
         string sql = "Select acct_num acnum, acct_name acname from [SendMnPro_Account].[dbo].[ac_master] a WITH(NOLOCK) where agent_id = " + GetStatic.GetAgent();
         DataSet ds = st.ExecuteDataset(sql);
         if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
         {
            foreach (DataRow row in ds.Tables[0].Rows)
            {
               ListItem listItem = new ListItem();
               listItem.Value = row["acnum"].ToString();
               listItem.Text = row["acname"].ToString();
               acInfo.Items.Add(listItem);
            }
         }
      }

      private void Authenticate()
      {
         _sl.CheckAuthentication(ViewFunctionId);
      }
   }
}