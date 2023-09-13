using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Transaction.CheckReferral
{
    public partial class CheckReferral : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20307000";
        private readonly StaticDataDdl sd = new StaticDataDdl();
        private readonly SwiftGrid _grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                //fromDate.Text= DateTime.Now.ToString("yyyy-MM-dd");
            }
            GetStatic.ResizeFrame(Page);
            Misc.MakeNumericTextbox(ref tranId);

        }
        private void Authenticate()
        {
            sd.CheckAuthentication(ViewFunctionId);
        }
    }
}