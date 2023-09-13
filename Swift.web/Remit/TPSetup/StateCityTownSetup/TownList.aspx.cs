using Swift.API.Common.SyncModel;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Helper.ThirdParty;
using Swift.DAL.Remittance.SyncDao;
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

namespace Swift.web.Remit.TPSetup.StateCityTownSetup
{
	public partial class TownList : System.Web.UI.Page
	{
		private const string GridName = "grid_list";
		private const string ViewFunctionId = "20700000";
		private const string AddEditFunctionId = "20700010";
		private readonly SwiftGrid _grid = new SwiftGrid();
		private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				GetStatic.PrintMessage(Page);
				Authenticate();
			}
			LoadGrid();

		}
		private void Authenticate()
		{
			swiftLibrary.CheckAuthentication(ViewFunctionId);
		}
		private void LoadGrid()
		{
			_grid.FilterList = new List<GridFilter>
								  {
									 new GridFilter("TOWN_NAME", "TOWN NAME", "T"),
								  };

			_grid.ColumnList = new List<GridColumn>
								  {
									  new GridColumn("SN", "SN", "", "T"),
									  new GridColumn("TOWN_NAME", "TOWN NAME", "", "T"),
									  new GridColumn("TOWN_CODE", "TOWN CODE", "", "T"),
									  new GridColumn("TOWN_COUNTRY", "TOWN COUNTRY", "", "T"),
									  new GridColumn("IS_ACTIVE", "IS ACTIVE", "", "T"),
									  new GridColumn("PAYMENT_TYPE", "PAYMENT TYPE", "", "T"),
								  };

			_grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			_grid.GridType = 1;
			_grid.GridName = GridName;
			_grid.ShowPagingBar = true;
			_grid.ShowAddButton = false;
			_grid.AllowEdit = false;
			_grid.AllowDelete = false;
			_grid.AddPage = "AddApiPartner.aspx";
			_grid.AlwaysShowFilterForm = true;
			_grid.ShowFilterForm = true;
			_grid.SortOrder = "ASC";
			_grid.RowIdField = "TOWN_ID";
			_grid.ThisPage = "TownList.aspx";
			_grid.AllowCustomLink = true;
			var link = "&nbsp;<a href=\"javascript:void(0);\" onclick=\"EnableDisable('@TOWN_ID','@TOWN_NAME','@IS_ACTIVE');\" class=\"btn btn-xs btn-primary\">Enable/Disable</a>";
			_grid.CustomLinkVariables = "TOWN_ID,TOWN_NAME,IS_ACTIVE";
			_grid.CustomLinkText = link;

			_grid.InputPerRow = 5;

			string sql = "EXEC [PROC_API_STATE_SETUP] @flag = 'S-Town',@cityId='" + GetCityrowId() + "'";

			_grid.SetComma();

			rpt_grid.InnerHtml = _grid.CreateGrid(sql);
		}

		private string GetCityrowId()
		{
			return GetStatic.ReadQueryString("cityrowId", "");
		}
		protected void btnUpdate_Click(object sender, EventArgs e)
		{
			StateCityTownDao _dao = new StateCityTownDao();
			if (!string.IsNullOrEmpty(isActive.Value))
			{
				var dbResult = _dao.EnableDisableTown(rowId.Value, GetStatic.GetUser(), isActive.Value);
				GetStatic.SetMessage(dbResult);
				Response.Redirect("TownList.aspx?cityId=" + GetCityRowId() + "");
			}
		}
		private string GetCityRowId()
		{
			return GetStatic.ReadQueryString("cityRowId", "");
		}
		private DataRow GetDetailsOfCity(string stateRowId)
		{
			StateCityTownDao _dao = new StateCityTownDao();
			return _dao.GetDetailsOfCity(GetCityRowId(), GetStatic.GetUser());
		}
	

		protected void btnSyncTown_Click(object sender, EventArgs e)
		{
			DataRow DetailsOfCity = GetDetailsOfCity(GetCityRowId());
			AddressRequest requestObj = new AddressRequest()
			{
				CountryIsoCode = DetailsOfCity["countryCode"].ToString(),
				ProviderId = DetailsOfCity["API_PARTNER_ID"].ToString(),
				MethodType = "town",
				CityId = DetailsOfCity["CITY_CODE"].ToString(),
				StateId = DetailsOfCity["STATE_CODE"].ToString(),
			};
			//AddressRequest requestObj = new AddressRequest()
			//{
			//	CountryIsoCode = "JP",
			//	ProviderId = "transfast",
			//	MethodType = "town",
			//	CityId = "43021",
			//	StateId = "NP001",
			//};

			SyncStateCityTownService serviceObj = new SyncStateCityTownService();
			var response = serviceObj.GetAddressList(requestObj);
			DbResult res = new DbResult();
			if (response.ResponseCode == "0")
			{
				BankBranchDao _dao = new BankBranchDao();
				var responseData = response.Data;
				var xml = ApiUtility.ObjectToXML(responseData);
				res = _dao.SyncTown(GetStatic.GetUser(), xml, DetailsOfCity["countryName"].ToString(), DetailsOfCity["STATE_ID"].ToString(),DetailsOfCity["CITY_ID"].ToString());

				if (res.ErrorCode == "0")
				{
					GetStatic.AlertMessage(this, res.Msg);
					Page_Load(this, EventArgs.Empty);
				}
				else
				{
					GetStatic.AlertMessage(this, "Bank Sycn Failed!!!!");
				}

			}
			else
			{
				GetStatic.AlertMessage(this, response.Msg);
			}

		}
	}
}