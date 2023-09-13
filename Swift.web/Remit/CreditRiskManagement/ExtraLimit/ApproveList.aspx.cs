using Swift.DAL.BL.Remit.CreditRiskManagement.CreditLimit;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Text;

namespace Swift.web.Remit.CreditRiskManagement.ExtraLimit
{
    public partial class ApproveList : System.Web.UI.Page
    {
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly SwiftGrid grid = new SwiftGrid();
        private const string ViewFunctionId = "20181700";
        private const string ApprovedId = "20181730";
        private const string GridName = "gridExtraLimitApproved";
        private readonly CreditLimitDao _obj = new CreditLimitDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                LoadGrid();
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
            {
                new GridFilter("agentName", "Agent Name", "T"),
                new GridFilter("approvedDate", "Approved Date", "z"),
                new GridFilter("extraLimit", "Amount", "T")
            };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("extraLimit", "Amount", "", "M"),
                                      new GridColumn("status", "status", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "D")
                                  };

            bool allowAddEdit = sl.HasRight(ViewFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.InputPerRow = 3;
            grid.RowIdField = "id";
            grid.GridWidth = 700;
            grid.CustomLinkVariables = "id";
            grid.AllowCustomLink = allowAddEdit;
            var customLinkText = new StringBuilder();
            if (sl.HasRight(ApprovedId))
            {
                customLinkText.Append("<input id=\"btnApprove_@id\" type=\"button\" value=\"Approve\" onclick=\"Approve(@id);\"></a>&nbsp;");
                customLinkText.Append("<input id=\"btnReject_@id\" type=\"button\" value=\"Reject\" onclick=\"Reject(@id);\"></a>&nbsp;");
            }
            grid.CustomLinkText = customLinkText.ToString();
            string sql = "[proc_extraLimit] @flag = 'S2'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            var dbResult = _obj.ApproveExtraLimit(GetStatic.GetUser(), hdnId.Value);
            ManageMessage(dbResult);
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            var dbResult = _obj.RejectExtraLimit(GetStatic.GetUser(), hdnId.Value);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            Response.Redirect("ApproveList.aspx");
        }
    }
}