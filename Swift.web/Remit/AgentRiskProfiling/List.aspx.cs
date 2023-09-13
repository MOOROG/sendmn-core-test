using Swift.DAL.BL.Remit.AgentRiskProfiling;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.AgentRiskProfiling
{
    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "gridagentRiskP";
        private string ViewFunctionId = "20191000";
        private string AddEditFunctionId = "20191010";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly agentRiskProfilingDao obj = new agentRiskProfilingDao();

        protected void Page_Load(object sender, EventArgs e)
        {
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

        private void makeInactive()
        {
            if (GetStatic.ReadQueryString("type", "") == "inactive")
            {
                var assessementId = GetStatic.ReadQueryString("aId", "");
                var agentId = GetStatic.ReadQueryString("agentId", "");

                var dbResult = obj.InactiveProfilingAgent(GetStatic.GetUser(), agentId, assessementId);
                //if (dbResult.ErrorCode.Equals("0"))
                //GetStatic.AlertMessage(Page, dbResult.Msg);
                //Response.Redirect("List.aspx");
                ManageMessage(dbResult);
            }
        }

        private void LoadGrid()
        {
            string ddlSql = "EXEC [proc_agentRiskProfiling] @flag = 'ddlStatus'";
            string ddlSql1 = "EXEC [proc_agentRiskProfiling] @flag = 'ddlRating'";
            //Commission/AgentCommissionRule/List.aspx
            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("assessementDate", "Assessement Date","D"),
                                     new GridFilter("agentid", "Agent", "a","","s-r-agent",true,"133"),
                                     new GridFilter("score", "Score", "T"),
                                     new GridFilter("rating", "Rating", "1:"+ddlSql1),
                                     new GridFilter("isActive","Status","1:" + ddlSql, "Y")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SNO", "", "T"),
                                      new GridColumn("assessementDate", "Assessement Date", "", "D"),
                                      new GridColumn("agentName", "Agent", "220", "T"),
                                      new GridColumn("score", "Score", "100", "M"),
                                      new GridColumn("rating", "Rating", "100", "T"),

                                      new GridColumn("createdBy", "Assessed By", "", "T"),
                                      new GridColumn("reviewdBy", "Reviewed By", "", "T"),
                                        new GridColumn("scorelink", "", "190", "T"),
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
            _grid.AddButtonTitleText = "Add New Agent Risk Profiling";
            _grid.AddPage = "Manage.aspx?type=new";
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "assessementId";
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 5;
            _grid.CustomLinkVariables = "assessementId,agentid";
            _grid.RowColoredByColValue1 = new string[] { "rating:high:#fd5e53", "rating:medium:#a1caf1", "rating:low:#87a96b" };

            /*
             *   _grid.AllowCustomLink = true;
            _grid.CustomLinkText = "<a href =\"" + GetStatic.GetUrlRoot() +
                                   "/Remit/AgentRiskProfiling/Manage.aspx?type=risk&aId=@assessementId&agentId=@agentid\">Score</a>";

            _grid.CustomLinkText += "&nbsp;&nbsp;<a href=\"" + GetStatic.GetUrlRoot() +
                                    "/Remit/AgentRiskProfiling/Manage.aspx?type=riskhistory&aId=@assessementId&agentId=@agentid\">History</a>";

            _grid.CustomLinkText += "&nbsp;&nbsp;<a href=\"" + GetStatic.GetUrlRoot() +
                                    "/Remit/AgentRiskProfiling/Manage.aspx?type=review&aId=@assessementId&agentId=@agentid\">Review</a>";

            _grid.CustomLinkText += "&nbsp;&nbsp;<a href=\"" + GetStatic.GetUrlRoot() +
                                    "/Remit/AgentRiskProfiling/List.aspx?type=inactive&aId=@assessementId&agentId=@agentid\">Mark Inactive</a>";
            */

            string sql = "EXEC [proc_agentRiskProfiling] @flag = 's'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void ManageMessage(DbResult dbResult)
        {
            var url = "List.aspx";

            GetStatic.CallJSFunction(this, string.Format("CallBackSave('{0}','{1}", dbResult.ErrorCode, dbResult.Msg.Replace("'", "") + "','" + url + "')"));
        }
    }
}