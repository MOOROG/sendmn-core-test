using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.GroupLocationMap
{
    public partial class List : Page
    {
        private const string GridName = "grd_locationGroup";
        private const string ViewFunctionId = "20111100";

        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();
        private readonly GroupLocationMapDao _obj = new GroupLocationMapDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                LoadGrid();
            }
            if (GetStatic.ReadQueryString("allowadd", "") == "Y")
            {
                if (GetStatic.ReadNumericDataFromQueryString("groupdetail") == 0)
                {
                    var dbResult = new DbResult();
                    dbResult.SetError("1", "Group detail is mandatory for adding a new group", "1");
                    ManageMessage(dbResult);
                }
                else
                    LoadGridAdd();
            }
            else
            {
                LoadGrid();
                DeleteRow();
            }
        }

        ////private void LoadGroupCat(ref DropDownList groupCat, string defaultValue)
        ////{
        ////    var sql = "SELECT typeID, typeDesc FROM staticDataType WHERE typeID = 6300";
        ////    _sdd.SetDDL(ref groupCat, sql, "typeID", "typeDesc", defaultValue, "");
        ////}

        private void LoadGrid()
        {
            btnFilter.Visible = true;
            //groupCat.Enabled = true;
            groupDetail.Enabled = true;
            agentGroupTab.InnerHtml = "<a href=\"#\" class=\"active\">Location Group List</a>";
            locationListTab.InnerHtml = "";

            _grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("locationCode", "District Id:", "T"),
                                      new GridFilter("districtName", "District Name:", "T")
                                  };
            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("districtId", "District Id", "", "T"),
                                      new GridColumn("districtName", "District Name", "", "T"),
                                      new GridColumn("createdBy",   "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "T")
                                  };
            if (!IsPostBack)
            {
                //LoadGroupCat(ref groupCat, GetStatic.ReadQueryString("groupcat", ""));
                LoadGroupDetail(ref groupDetail, GetStatic.ReadQueryString("groupdetail", ""));
            }
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Location";
            _grid.RowIdField = "rowId";
            _grid.AddPage = "List.aspx?allowadd=Y&groupcat=6300&groupdetail=" + groupDetail.Text;
            _grid.ShowAddButton = true;
            _grid.AllowEdit = false;
            _grid.AllowDelete = true;

            var grpDetail = groupDetail.Text != ""
                                ? groupDetail.Text
                                : _grid.FilterString(GetStatic.ReadQueryString("groupdetail", groupDetail.Text));
            string sql = "[proc_locationGroupMaping] @flag = 's'" +
                ",@GroupDetail = " + grpDetail +
                ",@GroupCat = 6300";
            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void LoadGridAdd()
        {
            btnFilter.Visible = false;
            //groupCat.Enabled = false;
            groupDetail.Enabled = false;
            groupDetail.Visible = true;
            // lLocation.InnerHtml = "<a href=\"#\" >List Location</a>";
            agentGroupTab.Attributes.Add("class", "deactive");
            agentGroupTab.InnerHtml = "<a href=\"List.aspx\" >Location Group List</a>";
            locationListTab.Attributes.Add("class", "active");
            locationListTab.InnerHtml = "<a href=\"#\">Location List</a>";

            _grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("locationCode", "District Id", "T"),
                                      new GridFilter("districtName", "District Name", "T")
                                  };
            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("districtId", "District Id", "", "T"),
                                      new GridColumn("districtName", "District Name", "", "T")
                                  };
            if (!IsPostBack)
            {
                //LoadGroupCat(ref groupCat, GetStatic.ReadQueryString("groupcat", ""));
                LoadGroupDetail(ref groupDetail, GetStatic.ReadQueryString("groupdetail", ""));
            }

            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = "locationAdd";
            _grid.MultiSelect = true;
            _grid.ShowCheckBox = true;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Location";
            _grid.RowIdField = "districtId";
            _grid.ShowAddButton = false;
            _grid.SortBy = "districtId";
            _grid.AllowEdit = false;
            _grid.AllowDelete = false;

            string sql = "[proc_locationGroupMaping] @flag = 'sG',@GroupDetail=" +
                            _grid.FilterString(GetStatic.ReadQueryString("groupdetail", "0")) +
                            ",@GroupCat=" + _grid.FilterString(GetStatic.ReadQueryString("groupcat", "0")) + "";
            _grid.SetComma();

            div_btn.Visible = true;
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?groupcat=6300&groupdetail=" + GetStatic.ReadQueryString("groupdetail", ""));
            }
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            _swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGroupDetail(ref DropDownList grpDetail, string defaultValue)
        {
            _sdd.SetStaticDdl(ref grpDetail, "6300", defaultValue, "Select Group Detail");
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = _obj.DeleteRow(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            string rsList = _grid.GetRowId((GetStatic.ReadQueryString("allowadd", "") == "Y" ? "locationAdd" : GridName));
            var dbResult = new DbResult();
            dbResult.Id = "1";
            dbResult.Msg = (GetStatic.ReadQueryString("groupcat", "") == "" ? "Group Category can't be blank" : (GetStatic.ReadQueryString("groupdetail", "") == "" ? "Group detail can't be blank" : ""));
            if (dbResult.Msg != "")
            {
                ManageMessage(dbResult);
                return;
            }
            dbResult = _obj.UpdateLocationMaping(GetStatic.GetUser(), rsList, GetStatic.ReadQueryString("groupcat", ""), GetStatic.ReadQueryString("groupdetail", ""));
            ManageMessage(dbResult);
        }

        protected void groupDetail_SelectedIndexChanged(object sender, EventArgs e)
        {
            //LoadGrid();
        }
    }
}