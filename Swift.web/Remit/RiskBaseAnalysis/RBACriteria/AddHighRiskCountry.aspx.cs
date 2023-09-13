using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using System.Data;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.DAL.BL.Remit.RiskBaseAnalysis;

namespace Swift.web.Remit.RiskBaseAnalysis.RBACriteria
{
    public partial class AddHighRiskCountry : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private RBACriteriaDao obj = new RBACriteriaDao();
        private string ViewFunctionId = "20191300";
        private string AddEditFunctionId = "20191310";
        protected const string GridName = "grid_HighRiskCountryList";
        private readonly SwiftGrid grid = new SwiftGrid();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            var type = GetStatic.ReadQueryString("type", "").ToLower();
            if (!IsPostBack)
            {
                Authenticate();
                if (type == "edit" || type == "delete")
                {
                    var id = GetStatic.ReadQueryString("id", "").ToLower();
                    if (type == "edit")
                    {
                        LoadData(id);
                    }
                    else
                    {
                        Delete(id);
                    }
                }
            }
            LoadGrid();
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }
        protected void btnAddCountry_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(country.Text))
            {
                r1.Visible = false;
                var dbResult = obj.SaveHighRiskCountry(GetStatic.GetUser(), country.Value, country.Text, chkBlockCountry.Checked);
                ManageMessage(dbResult, "AddHighRiskCountry.aspx");
            }
            else
            {
                r1.Visible = true;
            }
        }

        private void LoadGrid()
        {

            grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("countryName", "Country", "T"),                                       
                                   };

            grid.ColumnList = new List<GridColumn>
                        {
                            new GridColumn("sn", "SN", "4", "T"),
                            new GridColumn("countryName", "Country", "", "T"),
                            new GridColumn("blocked","Is Blocked","","T"),
                            new GridColumn("customlink", "", "190", "T")
                        };


            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;      
            grid.ShowPagingBar = true;
            grid.ThisPage = "AddHighRiskCountry.aspx";
            grid.RowIdField = "rowId";
            grid.SortBy = "rowId";
            grid.ShowFilterForm = true;
            grid.InputPerRow = 3;
            grid.SetComma();

            string sql = "EXEC proc_RBA @flag = 's-hrc'";
            grid.SetComma();
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Delete(string id)
        {            
            if (string.IsNullOrEmpty(id) || id == "0")
                return;

            var dbResult = obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult, "AddHighRiskCountry.aspx");
        }
        
        private void ManageMessage(DbResult dbResult, string url)
        {
            GetStatic.CallJSFunction(this, string.Format("CallBackSave('{0}','{1}", dbResult.ErrorCode, dbResult.Msg.Replace("'", "") + "','" + url + "')"));
        }

        void LoadData(string id)
        {
            if (string.IsNullOrEmpty(id) || id == "0")
                return;

            var drow = obj.GetDataByID(GetStatic.GetUser(), id);
            if (drow != null)
            {
                country.Value = drow["countryId"].ToString();
                country.Text = drow["countryName"].ToString();
                chkBlockCountry.Checked = (drow["isBlocked"].ToString() == "1" || drow["isBlocked"].ToString().ToLower() == "true") ? true : false;

                btnAddCountry.Visible = false;
                btnUpdateCountry.Visible = true;
            }

        }

        protected void btnUpdateCountry_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(country.Text))
            {
                r1.Visible = false;
                var id = GetStatic.ReadQueryString("id", "").ToLower();
                var dbResult = obj.UpdateHighRiskCountry(GetStatic.GetUser(), country.Value, country.Text, chkBlockCountry.Checked, id);

                ManageMessage(dbResult, "AddHighRiskCountry.aspx");
            }
            else
            {
                r1.Visible = true;
            }
        }
    }
}