using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using System.Collections.Generic;

namespace Swift.web.SwiftSystem.GeneralSetting.MessageSetting
{
    public partial class emailServerList : System.Web.UI.Page
    {
        private readonly MessageSettingDao obj = new MessageSettingDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private const string ViewFunctionId = "10111400";
        private const string AddEditFunctionId = "10111410";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private const string GridName = "emsetupserver";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                LoadGrid();
            }
        }
        private void LoadGrid()
        {
            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("id", "ID", "", "T"),
                                       new GridColumn("smtpServer", "SMTP Server", "", "T"),
                                       new GridColumn("smtpPort", "SMTP Port", "", "T"),
                                       new GridColumn("sendId", "EMAIL ID", "", "T"),
                                       new GridColumn("createdBy", "Created By", "", "T"),
                                       new GridColumn("createdDate", "Created Date", "", "D"),
                                   };
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 2;
            _grid.GridName = GridName;
            _grid.ShowAddButton = true;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "id";
            _grid.AllowEdit = true;
            _grid.AllowDelete = false;
            _grid.AddPage = "ManageEmailSeverSetup.aspx";
            const string sql = "SELECT id,smtpServer,smtpPort,sendId,createdBy,createdDate FROM emailServerSetup";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("ManageEmailSeverSetup.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }
    }
}