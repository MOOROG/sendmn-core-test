using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Administration.CustomerSetup.ApproveCustomer
{
    public partial class Pending : System.Web.UI.Page
    {
        private readonly CustomersDao _obj = new CustomersDao();
        private const string ViewFunctionId = "20111400";
        private const string ApproveFunctionId = "20111430";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string GridName = "app_info";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            GetStatic.PrintMessage(Page);
            if (!IsPostBack)
            {
                Authenticate();
                hdnStatus.Value = GetStatus();
                hdnZone.Value = GetZone();
                LoadApproveGrid();
            }
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadApproveGrid();
        }

        public string GetZone()
        {
            return GetStatic.ReadQueryString("zone", "");
        }

        public string GetStatus()
        {
            return GetStatic.ReadQueryString("status", "");
        }

        private void LoadApproveGrid()
        {
            bool allowApprove = _sdd.HasRight(ApproveFunctionId);
            var ds = _obj.GetCustomerListDashboard(GetStatic.GetUser(), hdnZone.Value, hdnStatus.Value);

            var dt = ds.Tables[0];
            var sb = new StringBuilder();
            var sbHead = new StringBuilder();
            int cols = dt.Columns.Count;
            int cnt = 0;
            var colIndex = -1;
            sbHead.Append("<table class='table table-responsive table-striped table-bordered' id =\"" + GridName + "_body\">");
            if (dt.Rows.Count > 0)
            {
                sb.Append("<tr>");
                for (int i = 1; i < cols; i++)
                {
                    var filterFunction = "ShowFilter(this, '" + GridName + "', " + (++colIndex) + ");";
                    var sortText = "<span style = \"float:left;cursor:pointer;height:30px;width:100%\" onclick =\"" + filterFunction + "\"><b>" + dt.Columns[i].ColumnName + "</b></span>";
                    sb.Append("<th>" + sortText + "</th>");
                }
                if (allowApprove)
                    sb.Append("<th></th>");
                sb.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    cnt = cnt + 1;
                    sb.AppendLine(cnt % 2 == 1
                                       ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                       : "<tr class=\"evenbg\"  onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
                    for (int i = 1; i < cols; i++)
                    {
                        sb.Append("<td>" + dr[i] + "</td>");
                    }
                    if (allowApprove)
                        sb.Append("<td><img style='cursor:pointer' title = 'View Details' alt = 'View Details' src = '" + GetStatic.GetUrlRoot() + "/images/view-detail-icon.png' onclick = 'ViewDetails(" + dr["customerId"].ToString() + ");' /></td>");
                    sb.Append("</tr>");
                }
            }
            sbHead.Append(sb.ToString());
            sbHead.Append("</table>");
            rptGrid.InnerHtml = sbHead.ToString();
            GetStatic.ResizeFrame(Page);
        }
    }
}