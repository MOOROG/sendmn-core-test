using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using Swift.DAL.BL.Remit.BranchRating;

namespace Swift.web.Remit.RiskBaseAnalysis.BranchRatingNEW
{

    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "gridBranchRatingNEW";
        private string ViewFunctionId = "20191600";
        private string AddEditFunctionId = "20191610";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly BranchRatingNEWDao obj = new BranchRatingNEWDao();

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
            string ddlSql = "EXEC [proc_branchRatingNEW] @flag = 'ddlStatus'";
            string ddlSql1 = "EXEC [proc_branchRatingNEW] @flag = 'ddlCategory'";
            string ddlSql2 = "EXEC [proc_branchRatingNEW] @flag = 'ddlRating'";

            _grid.FilterList = new List<GridFilter>
                                  {                                     
                                     new GridFilter("agentId", "Branch", "a","","branch",true,"13410"),                                    
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
                                      new GridColumn("BranchName", "Branch", "100", "T"),
                                      new GridColumn("rankedBy", "Ranked By", "", "T"),
                                      new GridColumn("rankingDate", "Ranking Date", "", "D"),
                                      new GridColumn("fromDate", "From", "60", "D"),
                                      new GridColumn("toDate", "To", "60", "D"),
                                      
                                      new GridColumn("operations", "Operation-General", "", "T"),
                                      new GridColumn("compliance", "Compliance-Regulatory", "", "T"),
                                      new GridColumn("security", "Security-Maintenance", "", "T"),
                                      
                                     // new GridColumn("others", "Others", "", "T"),
                                      new GridColumn("overall", "Over All", "", "T"),

                                      new GridColumn("reviewedDate", "Reviewed Date", "", "D"),
                                      new GridColumn("approvedDate", "Approved Date", "", "D"),                                      
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
            _grid.AddButtonTitleText = "Add New Branch for Rating";
            _grid.AddPage = "Manage.aspx?type=new";
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "brDetailid";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 5;
            _grid.CustomLinkVariables = "brDetailid,branchId";

            string sql = "EXEC [proc_branchRatingNEW] @flag = 'rbd'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
        void makeInactive()
        {
            if (GetStatic.ReadQueryString("type", "") == "inactive")
            {
                var brDetailId = GetStatic.ReadQueryString("brId", "");
                var branchId = GetStatic.ReadQueryString("bId", ""); ;

                var dbResult = obj.InactiveBranchRating(GetStatic.GetUser(), brDetailId, branchId);                
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