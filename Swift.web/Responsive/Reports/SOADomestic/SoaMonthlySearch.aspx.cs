using System;
using System.Data;
using Swift.DAL.BL.AgentPanel.Reports;
using Swift.web.Library;
using System.Web.UI.WebControls;

namespace Swift.web.Responsive.Reports.SOADomestic
{
    public partial class SoaMonthlySearch : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();
        private readonly SOAMonthlyDao _obj = new SOAMonthlyDao();
        private const string ViewFunctionId = "40112400";
        protected void Page_Load(object sender, EventArgs e)
        {
            _rl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                agent.Text = GetStatic.GetAgentName();
                PopulateDdl();
                SetCurrentYearMonth();
            }
        }

        private void Authenticate()
        {
            _rl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl()
        {
            for (var y = 2070; y < 2090; y++)
            {
                var Year = new ListItem { Value = y.ToString(), Text = y.ToString() };
                year.Items.Add(Year);
            }
        }

        private void SetCurrentYearMonth()
        {
            DataRow dr = _obj.GetNepYrMonth(GetStatic.GetUser());
            if (dr == null)
                return;
            year.SelectedValue = dr["npYear"].ToString();
            months.Text = dr["npMonth"].ToString();
        }
    }
}