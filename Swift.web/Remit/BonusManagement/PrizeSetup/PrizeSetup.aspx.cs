using Swift.DAL.Remittance.BonusManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;

namespace Swift.web.Remit.BonusManagement.PrizeSetup
{
	public partial class PrizeSetup : System.Web.UI.Page
	{
		readonly RemittanceLibrary sl = new RemittanceLibrary();
		readonly PrizeSetupDao psdao = new PrizeSetupDao();
		readonly StaticDataDdl sdl = new StaticDataDdl();
		private readonly SwiftGrid grid = new SwiftGrid();
		readonly RemittanceDao sd = new RemittanceDao();
		protected const string GridName = "grid_prizeSetup";
		private const string ViewFunctionId = "20821000";
		private const string AddEditFunctionId = "20821010";
		protected void Page_Load(object sender, EventArgs e)
		{
			Authenticate();
			Misc.MakeNumericTextbox(ref points);
			if (!IsPostBack)
			{
				if (GetBonusSchemeId() > 0)
					Populate(null);

				if (GetId() > 0)
				{
					Populate(GetId().ToString());
				}
			}
			LoadGrid();
		}

		private void DeleteRow()
		{
			string id = GetId().ToString();
			if (string.IsNullOrEmpty(id))
				return;

			DbResult dbResult = psdao.DeletePrize(GetStatic.GetUser(), id);
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
		private void Authenticate()
		{
			sl.CheckAuthentication(ViewFunctionId);
		}

		private void LoadGrid()
		{
			grid.ColumnList = new List<GridColumn>
                        {
                            new GridColumn("sn", "SN", "4", "T"),
                            new GridColumn("schemeName", "Scheme Name", "90", "T"),
                            new GridColumn("points", "Points", "90", "T"),
                            new GridColumn("giftItem", "Gift Items", "100", "T")
                        };

			bool allowAddEdit = sl.HasRight(AddEditFunctionId);
			grid.GridType = 1;
			grid.GridName = GridName;
			grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			grid.GridWidth = 500;
			grid.GridMinWidth = 500;
			grid.InputPerRow = 2;
			grid.AllowEdit = allowAddEdit;
			grid.AllowDelete = allowAddEdit;
			grid.EditCallBackFunction = "OpenInEditMode";
			grid.RowIdField = "schemePrizeId";
			grid.AddPage = "PrizeSetup.aspx";
			grid.ThisPage = "PrizeSetup.aspx";
			string sql = "EXEC proc_bonusOperationSetup @flag = 's' ,@bonusSchemeId =" + sd.FilterString(GetBonusSchemeId().ToString());
			grid.SetComma();
			rpt_grid.InnerHtml = grid.CreateGrid(sql);
		}

		protected int GetBonusSchemeId()
		{
			return Convert.ToInt32(Request.QueryString["bonusSchemeId"]);
		}

		private int GetId()
		{
			return GetStatic.ParseInt(hddDetailId.Value);
		}

		protected void Populate(string id)
		{
			if (id == null)
			{
				schemeName.Text = Request.QueryString["schemeName"].ToString();
				sdl.SetStaticDdl(ref giftItem, "7900");
			}
			else
			{
				DataRow dr = psdao.SelectPrizeById(GetStatic.GetUser(), GetId().ToString());
				schemeName.Text = dr["schemeName"].ToString();
				points.Text = dr["points"].ToString();
				giftImageFile.ImageUrl = GetStatic.GetUrlRoot() + "/Handler/Docs.ashx?id=" + dr["schemePrizeId"].ToString() + "&mode=bonusPrize" + "&file=" + dr["giftImage"];
				sl.SetDDL(ref giftItem, "EXEC proc_dropDownLists @flag= 'gift-item'", "valueId", "detailTitle", GetStatic.GetRowData(dr, "giftItem"), "");
			}

		}
		protected void btnSave_Click(object sender, EventArgs e)
		{
			ManagePrize();
		}

		private void ManagePrize()
		{
			string type = "doc";
			string root = "";
			string info = "";

			if (giftImage.PostedFile.FileName != null)
			{
				string pFile = giftImage.PostedFile.FileName.Replace("\\", "/");

				int pos = pFile.LastIndexOf(".");
				if (pos < 0)
					type = "";
				else
					type = pFile.Substring(pos + 1, pFile.Length - pos - 1);

				root = GetStatic.GetAppRoot(); //ConfigurationSettings.AppSettings["root"];

				string extension = Path.GetExtension(giftImage.PostedFile.FileName);
				string fileName = giftItem.SelectedItem.Text + "_" + GetTimestamp(DateTime.Now) + extension;
				info = UploadFile(giftImage.PostedFile.FileName, "", root);

				if (info.Substring(0, 5) == "error")
					return;

				DbResult dbResult = psdao.Update(GetStatic.GetUser(), GetId().ToString(), GetBonusSchemeId().ToString(), points.Text, giftItem.Text, fileName);
				if (dbResult.ErrorCode == "1")
				{
					ManageMessage(dbResult);
					return;
				}
				string locationToMove = root + "\\OtherDocuments\\Rewards" + "\\" + dbResult.Id;

				string fileToCreate = locationToMove + "\\" + fileName;

				if (File.Exists(fileToCreate))
					File.Delete(fileToCreate);

				if (!Directory.Exists(locationToMove))
					Directory.CreateDirectory(locationToMove);

				File.Move(info, fileToCreate);
				string strMessage = "File Uploaded Successfully";
				dbResult.SetError("0", strMessage, "");
				ManageMessage(dbResult);
			}
		}

		public string UploadFile(String fileName, string id, string root)
		{
			if (fileName == "")
			{
				return "error:Invalid filename supplied";
			}
			if (giftImage.PostedFile.ContentLength == 0)
			{
				return "error:Invalid file content";
			}
			try
			{
				if (giftImage.PostedFile.ContentLength <= 2048000)
				{
					string tmpPath = root + "\\doc\\tmp\\";

					if (!Directory.Exists(tmpPath))
						Directory.CreateDirectory(tmpPath);

					string saved_file_name = root + "\\doc\\tmp\\" + id + "_" + fileName;
					giftImage.PostedFile.SaveAs(saved_file_name);
					return saved_file_name;
				}
				else
				{
					return "error:Unable to upload,file exceeds maximum limit";
				}
			}
			catch (UnauthorizedAccessException ex)
			{
				return "error:" + ex.Message + "Permission to upload file denied";
			}
		}
		protected void btnEdit_Click(object sender, EventArgs e)
		{
			Populate(GetId().ToString());
		}

		protected void btnDelete_Click(object sender, EventArgs e)
		{
			DeleteRow();
		}

		public static string GetTimestamp(DateTime value)
		{
			var timeValue = value.ToString("hhmmssffffff");
			return timeValue + DateTime.Now.Ticks;
		}
	}
}