using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.Remittance.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Windows.Forms;

namespace Swift.web.Remit.TPSetup.TpApiRateSetup
{

    public partial class TpApiRateSetup : System.Web.UI.Page
    {
        private ThirdPartyExRateDao obj = new ThirdPartyExRateDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftTab _tab = new SwiftTab();
        private const string GridName = "grd_ars";
        private const string ViewFunctionId = "20600000";
        private const string AddEditFunctionId = "20600010";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.AlertMessage(Page);
                //LoadTab();
                LoadGrid();

            }

        }
        private void LoadGrid()
        {
            string _page_size = "10";
            string sortd = "ASC";
            int _page = 1;

            if (Request.Form["hdd_curr_page"] != null)
                _page = Convert.ToInt32(Request.Form["hdd_curr_page"].ToString());

            if (Request.Cookies["page_size"] != null)
                _page_size = Request.Cookies["page_size"].Value.ToString();

            if (Request.Form["ddl_per_page"] != null)
                _page_size = Request.Form["ddl_per_page"].ToString();

            Response.Cookies["page_size"].Value = _page_size;

            int page_size = Convert.ToUInt16(_page_size);

            var ds = obj.LoadGrid(GetStatic.GetUser(), _page.ToString(), page_size.ToString(), "rowId", "asc", country.Text, agent.Text);
            var dtPaging = ds.Tables[0];


            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<div class=\"responsive-table\">");
            html.Append("<table class=\"table table-responsive table-striped table-bordered\">");
            //html.Append(loadPagingBlock(dtPaging));
            html.Append("<tr>");
            html.Append("<th>SN</th>");
            html.Append("<th>Partner Name</th>");
            html.Append("<th>Country</th>");
            html.Append("<th>Settlement Avg Rate</th>");
            html.Append("<th><center>Margin</center></th>");
            html.Append("<th><center>Rate Margin over TF Rate</center></th>");
            html.Append("<th>Customer Rate</th>");
            html.Append("<th>Override TF CustRate</th>");
            html.Append("<th>Enable</th>");
            html.Append("<th>Update</th>");
            html.Append("</tr>");
            var allowAddEdit = _sdd.HasRight(AddEditFunctionId);
            foreach (DataRow dr in dt.Rows)
            {
                string checked1 = (dr["IS_ACTIVE"].ToString().ToLower() == "yes") ? "checked" : "";
                var id = Convert.ToInt32(dr["SN"]);
                var row_id = dr["ROW_ID"];
                html.Append("<tr id=\"row_" + id + "\" onclick=\"KeepRowSelection(" + id + "," + row_id + ");\">");
                html.Append("<td>" + id + "</th>");
                html.Append("<td>" + dr["Payout_Partner"] + "</th>");
                html.Append("<td>" + dr["Payout_Country"] + "</th>");
                //html.Append("<td><input class='form-control' disabled readonly=true id=\"settlementRate_" + id + "\" type =\"text\" value=\"" + dr["PARTNER_SETTLEMENT_RATE"] + "\"/>" + "</td>");
                html.Append("<td><input class='form-control' disabled readonly=true onchange=\"settlementChanged(this.value," + id+")\" id=\"settlementRate_" + id + "\" type =\"text\" value=\"" + dr["PARTNER_SETTLEMENT_RATE"] + "\"/>" + "</td>");
                html.Append("<td><input class='form-control' maxlength=6 onchange=\"marginChanged(this.value,"+id+")\" onkeypress=\"return isNumberKey(event,this.value);\" id=\"jmeMarginRate_" + id + "\" type =\"text\" value=\"" + dr["JME_MARGIN"] + "\"/>" + "</td>");
                html.Append("<td><input class='form-control' maxlength=6 onchange=\"rateMarginOverChanged(this.value," + id + ")\" onkeypress=\"return isNumberKey(event);\" id=\"rateMarginOverPartnerRate_" + id + "\" type =\"text\" value=\"" + dr["RATE_MARGIN_OVER_PARTNER_RATE"] + "\"/>" + "</td>");
                html.Append("<td><input class='form-control' disabled readonly=true id=\"partnerCustomerRate_" + id + "\" type =\"text\" value=\"" + dr["PARTNER_CUSTOMER_RATE"] + "\"/>" + "</td>");
                html.Append("<td><input class='form-control' onkeypress=\"return isNumberKey(event);\" id=\"overrideCustomerRate_" + id + "\" type =\"text\" value=\"" + dr["OVERRIDE_CUSTOMER_RATE"] + "\"/>" + "</td>");
                html.Append("<td><input type=\"checkbox\" id=\"isActive_" + id + "\" value=\"" + dr["IS_ACTIVE"] + "\"" + checked1 + " /></td>");
                if (allowAddEdit)
                    html.Append("<td><input id=\"btnUpdate_" + id + "\" type=\"button\" class='btn btn-primary m-t-25' disabled=\"disabled\" class=\"buttonDisabled\" onclick=\"UpdateRate(" + id + "," + row_id + ")\" value=\"Update\" title = \"Confirm Update\"/></td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            html.Append("</div>");
            rpt_grid.InnerHtml = html.ToString();
        }
        private void LoadTab()
        {
            _tab.NoOfTabPerRow = 2;
            _tab.TabList = new List<TabField>
                               {
                                   new TabField("ThirdParty Rate", "", true)
                               };
            var allowAddEdit = _sdd.HasRight(ViewFunctionId);
            if (allowAddEdit)
                //_tab.TabList.Add(new TabField("Add New", "Manage.aspx"));

                divTab.InnerHtml = _tab.CreateTab();
        }
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        protected void btnHidden_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }

        private string loadPagingBlock(DataTable dtPaging)
        {
            string pagingTable = "";
            foreach (DataRow row in dtPaging.Rows)
            {
                pagingTable = GetPagingBlock(int.Parse(row["totalRow"].ToString()), int.Parse(row["pageNumber"].ToString()), int.Parse(row["pageSize"].ToString()));
            }
            return pagingTable;
        }
        private string GetPagingBlock(int _total_record, int _page, int _page_size)
        {
            var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
            str.Append("<tr><td colspan='12'><table class='table table-bordered table-striped table-responsive'>");
            str.Append("<td class=\"GridTextNormal\" nowrap='nowrap'>Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
            str.Append("<select name=\"ddl_per_page\" onChange=\"submit_form();\">");
            str.Append("<option value=\"10\"" + autoSelect("10", _page_size.ToString()) + ">10</option>");
            str.Append("<option value=\"20\"" + autoSelect("20", _page_size.ToString()) + ">20</option>");
            str.Append("<option value=\"30\"" + autoSelect("30", _page_size.ToString()) + ">30</option>");
            str.Append("<option value=\"40\"" + autoSelect("40", _page_size.ToString()) + ">40</option>");
            str.Append("<option value=\"50\"" + autoSelect("50", _page_size.ToString()) + ">50</option>");
            str.Append("<option value=\"100\"" + autoSelect("100", _page_size.ToString()) + ">100</option>");
            str.Append("</select>&nbsp;&nbsp;per page&nbsp;&nbsp;");
            str.AppendLine("<select name=\"" + GridName + "_ddl_pageNumber\"  onChange=\"nav(this.value);\">");
            int remainder = _total_record % _page_size;
            int total_page = (_total_record - remainder) / _page_size;
            if (remainder > 0)
                total_page++;
            for (var i = 1; i <= total_page; i++)
            {
                str.AppendLine("<option value=\"" + i + "\"" + autoSelect(i.ToString(), _page.ToString()) + ">" + i + "</option>");
            }
            str.Append("</td>");
            str.AppendLine("<td align='right'>");

            if (_page > 1)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page - 1) + ", '" + GridName + "');\" title='Go to Previous page(Page : " + (_page - 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/prev.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disprev.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            if (_page * _page_size < _total_record)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"Nav(" + (_page + 1) + ", '" + GridName + "');\" title='Go to Next page(Page : " + (_page + 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/next.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disnext.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            str.AppendLine("<a href=\"Manage.aspx\" title=\"Add New Record\"><img src='" +
                                    GetStatic.GetUrlRoot() + "/images/add.gif' style=\"cursor: pointer;\" border='0'></a>");

            // str.AppendLine("&nbsp; <img title = 'Export to Excel' style = 'cursor:pointer' onclick = \"DownloadGrid('" + GetStatic.GetUrlRoot() + "');\"  src='" + GetStatic.GetUrlRoot() + "/images/excel.gif' border='0'>");

            str.AppendLine("</td>");
            str.AppendLine("</tr></table></td></tr>");


            return str.ToString();
        }
        private string autoSelect(string str1, string str2)
        {
            if (str1 == str2)
                return "selected=\"selected\"";
            else
                return "";
        }

        protected void btnMarkInactive_Click(object sender, EventArgs e)
        {

        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            var isActiveValue = (isActive.Value.ToLower() == "yes") ? "Y" : "N";
            var dbResult = obj.Update(GetStatic.GetUser(), settlementRate.Value, jmeMarginRate.Value,
                rateMarginOverPartnerRate.Value, partnerCustomerRate.Value, overrideCustomerRate.Value, isActive.Value, rowId.Value);
            ManageMessage(dbResult);
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("TpApiRateSetupList.aspx");
            }
            GetStatic.AlertMessage(Page);
        }

        protected void TextBox1_TextChanged(object sender, EventArgs e)
        {

        }
    }
}