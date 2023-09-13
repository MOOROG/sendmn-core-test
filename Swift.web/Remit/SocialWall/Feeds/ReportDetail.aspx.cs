using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.SocialWall.Feeds;
using Swift.web.Library;
using System.Runtime.Serialization;
using Newtonsoft.Json;
using System.Web.Script.Serialization;
using System.Text;
using System.Data;


namespace Swift.web.Remit.SocialWall.Feeds
{
    public partial class ReportDetail : System.Web.UI.Page
    {
        private const string GridName = "grd_ssc";
        //private readonly SwiftGrid _grid = new SwiftGrid();
        private string ViewFunctionId = "2022000";
        //private string AddEditFunctionId = "2022010";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        SocialWallGetReportDetails _socialwallDao = new SocialWallGetReportDetails();
        public string criteriaID;
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadGrid();
        }
        private void LoadGrid()
        {
            JavaScriptSerializer js = new JavaScriptSerializer();
            var _gridText = new StringBuilder();
            var _responseResult = GetGrid();
            dynamic myObject = JsonConvert.DeserializeObject(_responseResult.ToString());
            
            grdReport.DataSource = myObject; 
            grdReport.DataBind();
            grdReport.PageIndexChanged += new DataGridPageChangedEventHandler(dataGrid_PageIndexChanged);



        }
        void dataGrid_PageIndexChanged(object source, DataGridPageChangedEventArgs e)
        {
            if (source != null)
            {
                DataGrid dataGrid = source as DataGrid;
                dataGrid.CurrentPageIndex = e.NewPageIndex;
                dataGrid.DataBind();
            }
        }

        public DataTable DerializeDataTable(string data)
        {
            string json = data; //"data" should contain your JSON 
            dynamic table = JsonConvert.DeserializeObject<DataTable>(json);
            return table;
        }
        private object GetGrid()
        {

            var Feeds = _socialwallDao.GetReportDetails();
            var serializer = new JavaScriptSerializer();
            var serializedResult = serializer.Serialize(Feeds);
            // var deserializedResult = serializer.Deserialize<List<object>>(serializedResult);
            return serializedResult.ToString();

        }
    }
}