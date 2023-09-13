using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.web.Remit.Administration.AgentSetup.Functions
{
    public partial class AgentGroupMapping : System.Web.UI.Page
    {
        private const string GridName = "grd_appAgentGrpMaping";
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string DeleteFunctionId = "20111020";
        private const string ApproveFunctionId = "20111060";

        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly AgentGroupDao _obj = new AgentGroupDao();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                ShowHideTab();
                GetStatic.AlertMessage(Page);
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    var sql = "SELECT typeID, typeDesc FROM staticDataType WHERE typeID BETWEEN 6600 AND 6900";
                    _sdd.SetDDL(ref DDLGroupCat, sql, "typeID", "typeDesc", "", "Select Group Category");
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

        protected void ShowHideTab()
        {
            string agentType = GetAgentType().ToString();

            BusinessFunctionTab.Visible = true;
            BusinessFunctionTab.InnerHtml = "<a href=\"BusinessFunction.aspx?agentId=" + GetAgentId() + "&aType=" +
                                         GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Business Function</a>";

            if (agentType == "2902" || agentType == "2903" || GetActasBranch() == "Y")
            {
                //SendingCountry.Visible = true;
                //SendingCountry.InnerHtml = "<a href=\"SendingCountry/List.aspx?agentId=" + GetAgentId() + "&aType=" +
                //                               GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Sending Country</a>";
                //ReceivingCountry.Visible = true;
                //ReceivingCountry.InnerHtml = "<a href=\"ReceivingCountry/List.aspx?agentId=" + GetAgentId() + "&aType=" +
                //                               GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Receiving Country</a>";
            }

            if (GetActasBranch() == "Y" || agentType == "2904")
            {
                //RegionalBranchAccessSetup.Visible = true;
                //RegionalBranchAccessSetup.InnerHtml = "<a href=\"RegionalBranchAccessSetup.aspx?agentId=" + GetAgentId() + "&aType=" +
                //                             GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Regional Access Setup</a>";
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnDelete.Visible = _sl.HasRight(DeleteFunctionId);
            bntSubmit.Visible = _sl.HasRight(AddEditFunctionId);
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected string GetActasBranch()
        {
            return GetStatic.ReadQueryString("actAsBranch", "").ToString();
        }

        protected long GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType");
        }

        protected string GetAgentPageTab()
        {
            return "Agent Name : " + _sl.GetAgentName(GetAgentId().ToString());
        }

        protected void DDLGroupCat_SelectedIndexChanged(object sender, EventArgs e)
        {
            var sql = "SELECT valueId, detailDesc FROM staticDataValue WHERE typeID = " + _sdd.FilterString(DDLGroupCat.Text) + " AND ISNULL(IS_DELETE, 'N') = 'N' ORDER BY detailDesc ASC";
            _sdd.SetDDL(ref DDLGroupDetail, sql, "valueId", "detailDesc", "", "Select Group Detail");
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("AgentGroupMapping.aspx?agentId=" + GetAgentId());
            }
            else
            {
                GetStatic.AlertMessage(Page);
            }
        }

        private void Update()
        {
            DbResult dbResult = _obj.Update(GetStatic.GetUser(), GetId().ToString(), GetAgentId().ToString(), DDLGroupCat.Text,
                                           DDLGroupDetail.Text);
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
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "T")
                                  };
            grid.AllowEdit = _sdd.HasRight(AddEditFunctionId);

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.GridType = 1;

            grid.DisableJsFilter = true;
            grid.DisableSorting = true;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.EnableCookie = false;
            grid.ShowPagingBar = false;
            grid.AddButtonTitleText = "Add New ";
            grid.AllowApprove = true;
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.RowIdField = "rowId";
            grid.AddPage = "AgentGroupMapping.aspx?agentId=" + GetAgentId() + "&aType=" + GetAgentType() + "&actAsBranch=" + GetActasBranch() + "";

            grid.AllowEdit = _sdd.HasRight(AddEditFunctionId);
            grid.AllowDelete = _sdd.HasRight(DeleteFunctionId);
            grid.GridWidth = 900;

            string sql = "[proc_agentGroup] @flag = 's',@agentid = " + GetAgentId();
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