using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CustomerSetup.CustomerModifyLog
{
    public partial class List : Page
    {
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20131000";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
                PopulateDDl();
                fromDate.Text = DateTime.Now.ToString("yyyy/MM/dd");
                toDate.Text = DateTime.Now.ToString("yyyy/MM/dd");
            }
        }

        private void PopulateDDl()
        {
            _sdd.SetDDL(ref ddlSearchType, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(GetFunctionIdByUserType(null, ViewFunctionId));
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }
    }
}