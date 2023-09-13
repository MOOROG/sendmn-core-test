using Swift.DAL.BL.Remit.CreditRiskManagement.BalanceTopUp;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.InternationalOperation.BalanceTopUp
{
    public partial class Approve : System.Web.UI.Page
    {
        private const string GridName = "gridTopUpApproveList";
        private const string ViewFunctionId = "30011200";
        private const string ApproveFunctionId = "30011220";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly BalanceTopUpIntDao obj = new BalanceTopUpIntDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
            DeleteRow();
        }

        #region method
        protected string GetAgentName()
        {
            return "Agent Name : " + sl.GetAgentName(GetAgentId().ToString());
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("agentName", "Agent Name", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Agent", "", "T"),
                                      new GridColumn("amount", "Top Up Amount", "", "M"),
                                      new GridColumn("createdBy", "Requested By", "", "T"),
                                      new GridColumn("createdDate", "Requested Date", "", "T"),
                                  };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.AlwaysShowFilterForm = true;
            grid.ShowFilterForm = true;
            grid.EnableFilterCookie = false;
            grid.ShowPagingBar = true;
            grid.SortBy = "agentName";
            grid.RowIdField = "btId";
            grid.InputPerRow = 4;
            grid.AllowCustomLink = sl.HasRight(ApproveFunctionId);

            var customLinkText = new StringBuilder();
            customLinkText.Append("<input type=\"button\" class='btn btn-primary m-t-25' onclick = \"Approve(@btId)\" value=\"Approve\"/>&nbsp;");
            customLinkText.Append("<input type=\"button\" class='btn btn-primary m-t-25' onclick=\"Reject(@btId);\" value=\"Reject\"/>");
            grid.CustomLinkText = customLinkText.ToString();

            grid.CustomLinkVariables = "btId";

            string sql = "[proc_balanceTopUpInt] @flag = 'al'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            PrintMessage(dbResult);
        }

        private void PrintMessage(DbResult dbResult)
        {
            string data = GetStatic.ParseResultJsPrint(dbResult);
            string function = "printMessage('" + data + "')";
            GetStatic.CallBackJs1(this, "print", function);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("Approve.aspx");
            }
        }

        protected void btnCallBack_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnId.Value))
                return;
            var dbResult = obj.Approve(GetStatic.GetUser(), hdnId.Value);
            ManageMessage(dbResult);
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnId.Value))
                return;
            var dbResult = obj.Reject(GetStatic.GetUser(), hdnId.Value);
            ManageMessage(dbResult);
        }
    }
}