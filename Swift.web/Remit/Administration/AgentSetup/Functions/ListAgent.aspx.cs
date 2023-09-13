using Swift.DAL.BL.SwiftSystem;
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

namespace Swift.web.Remit.Administration.AgentSetup.Functions
{
    public partial class ListAgent : System.Web.UI.Page
    {
        private const string GridName = "gridAgMaster1";
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string ApproveFunctionId = "20111030";
        private const string ViewUserFunctionId = "20111000";
        private const string AgentInfoFid = "20111050";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        public string GetGridName()
        {
            return GridName;
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            string ddlSql = "EXEC [proc_staticDataValue] @flag = 'l', @typeID = 2900";
            //string ddlSql2 = "EXEC [proc_staticDataValue] @flag = 'l', @typeId = 4300";

            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("haschanged", "Change Status",
                                                     "2"),
                                      new GridFilter("agentCode", "Code", "LT"),
                                      new GridFilter("businessType", "Business Type","1:EXEC proc_staticDataValue 'listAgent','6200','' "),
                                      new GridFilter("isActive", "Is Active", "2"),
                                      new GridFilter("agentCountry", "Country",
                                                     "1:EXEC [proc_countryMaster] @flag = 'cl2'"),
                                      new GridFilter("agentType", "Type", "1:" + ddlSql),
                                      new GridFilter("agentName", "Name", "LT"),
                                      new GridFilter("agentBlock", "Is Blocked", "2")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Name", "", "T"),
                                      new GridColumn("countryName", "Country", "", "T"),
                                      new GridColumn("agentState", "State", "", "T"),
                                      new GridColumn("agentLocation", "Location", "", "T"),
                                      new GridColumn("agentDistrict", "District", "", "T"),
                                      new GridColumn("agentAddress", "Agent Address", "", "T"),
                                      new GridColumn("agentPhone1", "Contact No1.", "", "T"), 
                                      new GridColumn("agentPhone2", "Contact No2.", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.LoadGridOnFilterOnly = true;
            grid.ShowFilterForm = true;
            grid.AlwaysShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New User";
            grid.RowIdField = "agentId";
            grid.ThisPage = "ListAgent.aspx";
            grid.GridMinWidth = 800;
            grid.IsGridWidthInPercent = true;
            grid.GridWidth = 100;
            grid.InputPerRow = 4;
            grid.AllowEdit = false;

            grid.AllowApprove = swiftLibrary.HasRight(ApproveFunctionId);
            grid.ApproveFunctionId = ApproveFunctionId;

            grid.AddPage = "../Manage.aspx";
            grid.AllowCustomLink = allowAddEdit;
            var customLinkText = new StringBuilder();
            if (allowAddEdit)
                customLinkText.Append(
                    "<a href=\"#\" onclick=\"ManageAgent(@agentId, @agentType, @parentId,'" +GetActAsBranchFlag() + "')\"><img src = \"" +
                    GetStatic.GetUrlRoot() + "/images/edit.gif\" border=0 alt = \"Edit\" title=\"Edit\" /></a>&nbsp;&nbsp;");
            //if (swiftLibrary.HasRight(AgentInfoFid))
            //    customLinkText.Append("<a href=\"../AgentInfo/List.aspx?agentId=@agentId\"><img src = \"" +
            //                      GetStatic.GetUrlRoot() +
            //                      "/images/info.gif\" border=0 alt = \"Info\" title=\"Info\" /></a>&nbsp;&nbsp;");
            //if (swiftLibrary.HasRight(ViewUserFunctionId))
            //    customLinkText.Append(
            //        "<a href=\"" + GetStatic.GetUrlRoot() + "/SwiftSystem/UserManagement/ApplicationUserSetup/List.aspx?agentId=@agentId&mode=2\"><img src = \"" +
            //        GetStatic.GetUrlRoot() + "/images/user_icon.gif\" border=0 alt = \"Users\" title=\"Users\" /></a>");
            grid.CustomLinkText = customLinkText.ToString();
            grid.CustomLinkVariables = "agentId,agentType,parentId";

            string sql = "[proc_agentMaster] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
        protected string GetActAsBranchFlag()
        {
            return GetStatic.ReadQueryString("actAsBranch", "N");
        }

        private void DeleteRow()
        {
            var abf = new AgentDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = abf.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        #endregion
    }
}