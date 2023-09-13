using Swift.DAL.Remittance.BonusManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.BonusManagement.OperationStartSetup
{
	public partial class List : System.Web.UI.Page
	{
		protected const string GridName = "grid_schemeList";
		private readonly SwiftGrid grid = new SwiftGrid();
		readonly SwiftLibrary sl = new SwiftLibrary();
		readonly PrizeSetupDao psdao = new PrizeSetupDao();
		private const string ViewFunctionId = "20821000";
		private const string AddEditFunctionId = "20821010";
		private const string DeleteFunctionId = "20821020";
		protected void Page_Load(object sender, EventArgs e)
		{
			Authenticate();
			LoadGrid();
			DeleteRow();
		}
		private void Authenticate()
		{
			sl.CheckAuthentication(ViewFunctionId + "," + DeleteFunctionId);
		}
		private void DeleteRow()
		{
			string id = grid.GetCurrentRowId(GridName);
			if (string.IsNullOrEmpty(id))
				return;

			DbResult dbResult = psdao.Delete(GetStatic.GetUser(), id);
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

		private void LoadGrid()
		{
			grid.FilterList = new List<GridFilter>
                        {                           
                            new GridFilter("schemeName", "Scheme Name", "T"),
                            new GridFilter("sendingCountry", "Sending Country", "T"),
                            new GridFilter("receivingCountry", "Receving Country", "T")
                        };

			grid.ColumnList = new List<GridColumn>
                        {
                            new GridColumn("sn", "SN", "4", "T"),
                            new GridColumn("schemeName", "Scheme Name", "90", "T"),
                            new GridColumn("sendingCountry", "Sen. Country", "90", "T"),
                            new GridColumn("sendingAgent", "Sen. Agent", "100", "T"),
                            new GridColumn("receivingCountry", "Rec. Country", "70", "T"),
                            new GridColumn("receivingAgent", "Rec. Agent", "100", "T"),
                            new GridColumn("schemeStartDate", "Start Date", "60", "z"),
                            new GridColumn("schemeEndDate", "End Date", "60", "z")
                         
                        };

			bool allowAddEdit = sl.HasRight(AddEditFunctionId);
			grid.GridType = 1;
			grid.GridName = GridName;
			grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			grid.ShowFilterForm = true;
			grid.InputPerRow = 3;
			grid.AllowEdit = allowAddEdit;
			grid.AllowDelete = allowAddEdit;
			grid.AddButtonTitleText = "Add New";
			grid.Downloadable = false;
			grid.InputLabelOnLeftSide = false;
			grid.ShowAddButton = true;
			grid.ShowPagingBar = true;
			grid.AllowCustomLink = true;
			grid.CustomLinkText = @"<a  href = ""../PrizeSetup/PrizeSetup.aspx?bonusSchemeId=@bonusSchemeId&schemeName=@schemeName"" >" + Misc.GetIcon("ps") + "</a>";
			grid.CustomLinkVariables = "bonusSchemeId,schemeName";
			grid.RowIdField = "bonusSchemeId";
			grid.AddPage = "Manage.aspx";
			grid.ThisPage = "List.aspx";
			string sql = "EXEC proc_bonusOperationSetup @flag = 'scheme-list'";
			grid.SetComma();
			rpt_grid.InnerHtml = grid.CreateGrid(sql);
		}
	}
}