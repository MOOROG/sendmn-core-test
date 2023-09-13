using Swift.DAL.BL.SwiftSystem;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup
{
    public partial class UserGroupMaping : System.Web.UI.Page
    {
        private const string GridName = "grd_appUsrGrpMaping";
        private const string ViewFunctionId = "10101300";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly UserGroupMappingDao _obj = new UserGroupMappingDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                GetStatic.SetActiveMenu(ViewFunctionId);

                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    var sql = "select typeID, typeDesc from staticDataType where typeID BETWEEN 6600 AND 6900 ";
                    _sdd.SetDDL(ref DDLGroupCat, sql, "typeID", "typeDesc","", "Select Group Category");

                    sql = "select valueid, detailDesc from staticDataValue where typeID = " + _sdd.FilterString(DDLGroupCat.Text) + " ORDER BY detailDesc ASC";
                    _sdd.SetDDL(ref DDLGroupDetail, sql, "valueid", "detailDesc", "", "Select Group Detail");
                }
            }
            DeleteRow();
            LoadGrid();
        }
        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            var sql = "SELECT typeID, typeDesc FROM staticDataType WHERE typeID BETWEEN 6600 AND 6900";
            _sdd.SetDDL(ref DDLGroupCat, sql, "typeID", "typeDesc", dr["groupCat"].ToString(), "Select Group Category");

            sql = "SELECT valueId, detailDesc FROM staticDataValue WHERE typeID = " + _sdd.FilterString(DDLGroupCat.Text) + " ORDER BY detailDesc ASC";
            _sdd.SetDDL(ref DDLGroupDetail, sql, "valueid", "detailDesc", dr["groupDetail"].ToString(), "Select Group Detail");
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }
        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }
        protected long GetAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }
        protected long GetUserId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }
        protected string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        protected void DDLGroupCat_SelectedIndexChanged(object sender, EventArgs e)
        {
            var sql = "select valueid, detailDesc from staticDataValue where typeID = " + _sdd.FilterString(DDLGroupCat.Text);
            _sdd.SetDDL(ref DDLGroupDetail, sql, "valueid", "detailDesc", "", "Select Group Detail");
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("UserGroupMaping.aspx?userId=" + GetUserId() + "&userName=" + GetUserName());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }
        private void Update()
        {
            DbResult dbResult = _obj.Update(GetStatic.GetUser(), GetId().ToString(), GetUserId().ToString(), DDLGroupCat.Text,
                                           DDLGroupDetail.Text, GetUserName());
            ManageMessage(dbResult);
        }
        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = _obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }
        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("GroupCat", "Group Category", "", "T"),
                                      new GridColumn("SubGroup", "Group Detail", "", "T"),
                                      new GridColumn("userName", "User Name", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "T")
                                  };

            grid.GridName = GridName;
            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.DisableJsFilter = true;
            grid.DisableSorting = true;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
         //   grid.AllowApprove = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "rowId";
            grid.AddPage = "UserGroupMaping.aspx?userId=" + GetUserId() + "&userName=" + GetUserName();

            grid.AllowEdit = true;
            grid.AllowDelete = true;
            //grid.AllowDelete = _sdd.HasRight(DeleteFunctionId);
            grid.GridWidth = 1020;

            string sql = "EXEC proc_userGroupMapping @flag = 's', @userId = " + GetUserId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }
        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            Update();
        }
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DDLGroupCat.Text = "";
            DDLGroupDetail.Items.Clear();
        }
    }
}