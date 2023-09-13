using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.Document
{
    public partial class List : Page
    {
        private const string GridName = "grid_docList";
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        public string GetGridName()
        {
            return GridName;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnl1.Visible = GetMode().ToString() == "1";
                Authenticate();
                if (GetMode() == 2)
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRows();
        }

        #region QueryString

        protected string GetAgentName()
        {
            return remitLibrary.GetAgentBreadCrumb(GetAgentId().ToString());
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        protected long GetParentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("parent_id");
        }

        protected string GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType").ToString();
        }

        protected string GetActAsBranchFlag()
        {
            return GetStatic.ReadQueryString("actAsBranch", "");
        }

        #endregion QueryString

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("fileDescription", "File Description", "LT"),
                                      new GridFilter("fileType", "File Type", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("fileDescription", "File Description", "", "T"),
                                      new GridColumn("fileType", "File Type", "", "T")
                                  };

            bool allowAddEdit = remitLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New Document";
            grid.RowIdField = "adId";
            grid.ThisPage = "List.aspx";
            grid.ViewFunctionId = ViewFunctionId;

            grid.AllowFileView = remitLibrary.HasRight(ViewFunctionId);
            grid.ShowCheckBox = true;
            grid.MultiSelect = true;
            grid.AllowEdit = false;
            grid.AllowDelete = false;

            //grid.EditText = "<img src = \"/images/edit.gif\" border=0 alt = \"Edit\" />";
            //grid.DeleteText = "<img src = \"/images/delete.gif\" border=0 alt = \"Delete\" />";

            grid.AddPage = "Manage.aspx?agentId=" + GetAgentId() + "&mode=" + GetMode() + "&parent_id=" + GetParentId() +
                           "&aType=" + GetAgentType();

            string sql = "[proc_agentDocument] @flag = 's', @agentId = " + GetAgentId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRows()
        {
            var obj = new AgentDocumentDao();
            string adIds = grid.GetRowId(GridName);
            if (string.IsNullOrEmpty(adIds))
                return;

            string root = GetStatic.GetDefaultDocPath(); //ConfigurationSettings.AppSettings["root"];
            DataTable dt = obj.Delete(GetStatic.GetUser(), adIds);

            foreach (DataRow row in dt.Rows)
            {
                if (File.Exists(root + "\\doc\\" + row[0]))
                {
                    File.Delete(root + "\\doc\\" + row[0]);
                }
            }

            LoadGrid();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        #endregion method
    }
}