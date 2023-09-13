using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Component.Grid;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid.gridHelper;
using System.Text;
using Swift.DAL.BL.System.GeneralSettings;


namespace Swift.web.SwiftSystem.GeneralSetting.FieldSetting
{
    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "grid_fieldList";
        private readonly SwiftGrid grid = new SwiftGrid();
        readonly RemittanceLibrary sl = new RemittanceLibrary();
        readonly FieldSettingDao fsd = new FieldSettingDao();
        private const string ViewFunctionId = "10122700";
        private const string AddEditFunctionId = "10122710";
        private const string DeleteFunctionId = "10122720";
        protected void Page_Load(object sender, EventArgs e)
        {

            Authenticate();
            LoadGrid();
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId + "," + DeleteFunctionId);
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                        {                           
                            new GridFilter("country", "Country", "T"),
                            new GridFilter("agent", " Agent", "T"),
                            new GridFilter("opeType", "Type", "T")
                        };

            grid.ColumnList = new List<GridColumn>
                        {
                            new GridColumn("sn", "SN", "4", "T"),
                            new GridColumn("country", "Country", "90", "T"),
                            new GridColumn("agentName", "Agent", "100", "T"),
                            new GridColumn("opeType", "Type", "70", "T"),
                            new GridColumn("createdBy", "Created By", "100", "T"),
                            new GridColumn("createdDate", "Created Date", "60", "z")
                        };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.GridWidth = 700;
            grid.GridMinWidth = 700;
            grid.InputPerRow = 3;
            grid.Downloadable = false;
            grid.InputLabelOnLeftSide = false;
            grid.ShowPagingBar = true;
            grid.AllowCustomLink = true;
            grid.RowIdField = "rowId";
            var htmlLink = new StringBuilder();
            grid.CustomLinkVariables = "opeType,rowId";
            htmlLink.Append(@"<a title = ""Edit"" href=""javascript:void(0)"" onclick = ""OpenInEditMode('@rowId','@opeType'); ""><img class = ""showHand"" border = ""0"" title = ""Edit"" src=""../../../Images/edit.gif"" /></a>");
            htmlLink.Append(@"<a title = ""Delete"" href=""javascript:void(0)"" onclick = ""DeleteRow('@rowId'); ""><img class = ""showHand"" border = ""0"" title = ""Delete"" src=""../../../Images/delete.gif"" /></a>");
            grid.CustomLinkText = htmlLink.ToString();
            grid.ThisPage = "List.aspx";
            string sql = "EXEC proc_sendPayTable @flag = 's'";
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected void btnRedirectPage_Click(object sender, EventArgs e)
        {
             var id = GetStatic.ParseInt(hddDetailId.Value);
             var type = hdDetailType.Value;
             if (type == "Send")
                 Response.Redirect("Send.aspx?rowId=" + id);
             else
                 Response.Redirect("Receive.aspx?rowId=" + id);
                
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        private void DeleteRow()
        {
            string id = (hddDetailId.Value).ToString();
            if (string.IsNullOrEmpty(id))
                return;

            DbResult dbResult = fsd.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }
        private void ManageMessage(DbResult dbResult)
        {

            if (dbResult.ErrorCode == "0")
            {
                LoadGrid();
            }
            GetStatic.PrintMessage(Page, dbResult);
        }
    }
}