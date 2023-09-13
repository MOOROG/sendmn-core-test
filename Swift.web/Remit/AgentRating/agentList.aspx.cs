using Swift.DAL.BL.Remit.AgentRating;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.AgentRating
{
    public partial class agentList : System.Web.UI.Page
    {
        protected const string GridName = "gridAgentRatingAgentList";
        private string ViewFunctionId = "20191200";
        private string AddEditFunctionId = "20191210";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly AgentRatingDao obj = new AgentRatingDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                makeInactive();
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            string ddlSql = "EXEC [proc_agentRating] @flag = 'ddlStatus'";
            string ddlSql1 = "EXEC [proc_agentRating] @flag = 'ddlCategory'";
            string ddlSql2 = "EXEC [proc_agentRating] @flag = 'ddlRating'";

            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("agentId", "Agent", "a","","CountryAgent",true,"133"),
                                     new GridFilter("fromDate", "From Date","D"),
                                     new GridFilter("toDate", "To Date","D"),
                                      new GridFilter("reviewedDate", "Review Date","D"),
                                     new GridFilter("approvedDate", "Approve Date","D"),
                                     new GridFilter("category", "Category", "1:"+ddlSql1),
                                     new GridFilter("rating", "Category-Rating", "1:"+ddlSql2),
                                     new GridFilter("isActive","Status","1:" + ddlSql, "Y")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SNO", "", "T"),
                                      new GridColumn("AgentName", "Agent", "100", "T"),
                                      new GridColumn("rankedBy", "Ranked By", "", "T"),
                                      new GridColumn("rankingDate", "Ranking Date", "", "D"),
                                      new GridColumn("fromDate", "From", "60", "D"),
                                      new GridColumn("toDate", "To", "60", "D"),

                                      new GridColumn("general", "General Risk Factors", "", "T"),
                                      new GridColumn("operations", "Operations", "", "T"),
                                      new GridColumn("security", "Security", "", "T"),
                                      new GridColumn("compliance", "Compliance", "", "T"),
                                      new GridColumn("others", "Others", "", "T"),
                                      new GridColumn("overall", "Over All", "", "T"),

                                      new GridColumn("reviewedDate", "Reviewed Date", "", "D"),
                                      new GridColumn("approvedDate", "Approved Date", "", "D"),
                                      new GridColumn("scorelink", "", "", "T"),
                                  };
            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AllowDelete = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.ShowAddButton = allowAddEdit;
            _grid.AddButtonTitleText = "Add New Agent for Rating";
            _grid.AddPage = "Manage.aspx?type=new";
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "arDetailid";
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 5;
            _grid.CustomLinkVariables = "arDetailid,agentId";

            string sql = "EXEC [proc_agentRating] @flag = 'rad-agent'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void makeInactive()
        {
            if (GetStatic.ReadQueryString("type", "") == "inactive")
            {
                var arDetailId = GetStatic.ReadQueryString("arId", "");
                var agentId = GetStatic.ReadQueryString("aId", "");
                var dbResult = obj.InactiveAgentRating(GetStatic.GetUser(), arDetailId, agentId);
                ManageMessage(dbResult);
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            var url = "List.aspx";

            GetStatic.CallJSFunction(this, string.Format("CallBackSave('{0}','{1}", dbResult.ErrorCode, dbResult.Msg.Replace("'", "") + "','" + url + "')"));
        }
    }
}