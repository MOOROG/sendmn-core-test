using Swift.DAL.BL.Remit.ExchangeRate;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.ExchangeRate.AgentRateSetup
{
    public partial class ApproveList : System.Web.UI.Page
    {
        private DefExRateDao obj = new DefExRateDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string GridName = "grd_arsApp";
        private const string ViewFunctionId = "30012400";
        private const string ApproveFunctionId = "30012430";

        private string chkList = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            chkList = Request.Form["chkId"];
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private string autoSelect(string str1, string str2)
        {
            if (str1 == str2)
                return "selected=\"selected\"";
            else
                return "";
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ApproveFunctionId);
            btnApprove.Visible = _sdd.HasRight(ApproveFunctionId);
            btnReject.Visible = _sdd.HasRight(ApproveFunctionId);
        }

        private string GetPagingBlock(int _total_record, int _page, int _page_size)
        {
            var str = new StringBuilder("<input type = \"hidden\" name=\"hdd_curr_page\" id = \"hdd_curr_page\" value=\"" + _page.ToString() + "\">");
            str.Append("<table width=\"100%\" cellspacing=\"2\" cellpadding=\"2\" border=\"0\">");
            str.Append("<tr>");
            str.Append("<td width=\"247\" class=\"GridTextNormal\" nowrap='nowrap'>Result :&nbsp;<b>" + _total_record.ToString() + "</b>&nbsp;records&nbsp;");
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
            str.AppendLine("<td width=\"100%\" align='right'>");

            if (_page > 1)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"nav(" + (_page - 1) + ");\" title='Go to Previous page(Page : " + (_page - 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/prev.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disprev.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            if (_page * _page_size < _total_record)
                str.AppendLine("<img style = \"cursor:pointer\" onclick =\"nav(" + (_page + 1) + ");\" title='Go to Next page(Page : " + (_page + 1) + ")' src='" + GetStatic.GetUrlRoot() + "/images/next.gif' border='0'>&nbsp;&nbsp;&nbsp;");
            else
                str.AppendLine("<img src='" + GetStatic.GetUrlRoot() + "/images/disnext.gif' border='0'>&nbsp;&nbsp;&nbsp;");

            //str.AppendLine("<a href=\"Manage.aspx\" title=\"Add New Record\"><img src='" +
            //                        GetStatic.GetUrlRoot() + "/images/add.gif' border='0'></a>");

            // str.AppendLine("&nbsp; <img title = 'Export to Excel' style = 'cursor:pointer' onclick
            // = \"DownloadGrid('" + GetStatic.GetUrlRoot() + "');\" src='" + GetStatic.GetUrlRoot()
            // + "/images/excel.gif' border='0'>");

            str.AppendLine("</td>");
            str.AppendLine("</tr></table>");

            return str.ToString();
        }

        private void loadPagingBlock(DataTable dtPaging)
        {
            foreach (DataRow row in dtPaging.Rows)
            {
                paginDiv.InnerHtml = GetPagingBlock(int.Parse(row["totalRow"].ToString()), int.Parse(row["pageNumber"].ToString()), int.Parse(row["pageSize"].ToString()));
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

            var ds = obj.LoadGridApprove(GetStatic.GetUser(), "AG", _page.ToString(), _page_size, "defExRateId", sortd, "Y", currency.Text, country.Text, agent.Text);
            var dtPaging = ds.Tables[0];
            loadPagingBlock(dtPaging);
            var dt = ds.Tables[1];
            var html = new StringBuilder();
            html.Append("<table  class=\"gridTable\" width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" border=\"0\">");
            html.Append("<tr class=\"hdtitle\">");
            html.Append("<th rowspan=\"2\" Class=\"headingTH\" nowrap = \"nowrap\"><a href=\"javascript:void(0);\" onClick=\"CheckAll(this)\">√</a></th>");
            html.Append("<th rowspan=\"2\" class=\"headingTH\">Country</th>");
            html.Append("<th rowspan=\"2\" class=\"headingTH\">Currency</th>");
            html.Append("<th rowspan=\"2\" class=\"headingTH\">Agent</th>");
            html.Append("<th rowspan=\"2\" class=\"headingTH\">TXN Type</th>");
            html.Append("<th rowspan=\"2\" class=\"headingTH\">Mode</th>");
            html.Append("<th rowspan=\"2\" class=\"headingTH\">Value</th>");
            html.Append("<th rowspan=\"2\" class=\"headingTH\">Factor</th>");
            html.Append("<th colspan=\"3\" class=\"headingTH\"><center> Collection</center></th>");
            html.Append("<th colspan=\"3\" class=\"headingTH\"><center>Payment</center></th>");
            html.Append("</tr><tr class=\"hdtitle\">");

            html.Append("<th class=\"headingTH\">Rate</th>");
            html.Append("<th class=\"headingTH\">Margin</th>");
            html.Append("<th class=\"headingTH\">Offer</th>");
            html.Append("<th class=\"headingTH\">Rate</th>");
            html.Append("<th class=\"headingTH\">Margin</th>");
            html.Append("<th class=\"headingTH\">Offer</th>");
            html.Append("</tr>");

            foreach (DataRow dr in dt.Rows)
            {
                var id = Convert.ToInt32(dr["defExRateId"]);
                html.Append("<tr class=\"evenbg\">");

                if (dr["modifiedby"].ToString() != GetStatic.GetUser())
                {
                    html.Append("<td align=\"center\" rowspan=\"2\"><input type='checkbox' id = \"chk_" + id + "\" name ='chkId' value='" + id + "' " + (id.ToString() != "" ? "checked='checked'" : "") + " /></td>");
                }
                else
                {
                    html.Append("<td align=\"center\" rowspan=\"2\">&nbsp;</td>");
                }
                html.Append("<td rowspan=\"2\">" + dr["countryName"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["currency"] + "(" + dr["currencyName"] + ")" + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["agentName"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["tranTypeName"] + "</td>");
                html.Append("<td rowspan=\"2\">" + dr["modType"] + "</td>");

                html.Append("<td align=\"center\"><b>Old</b></td>");
                if (dr["factorOld"].ToString() == "M")
                {
                    html.Append("<td align=\"center\">MUL</td>");
                }
                else
                {
                    html.Append("<td align=\"center\">DIV</td>");
                }

                switch (dr["cOperationType"].ToString())
                {
                    case "B":
                        html.Append("<td class='tdCollApp'>" + dr["cRateOld"] + "</td>");
                        html.Append("<td class='tdCollApp'>" + dr["cMarginOld"] + "</td>");
                        html.Append("<td class='tdCollApp'>" + dr["cOfferOld"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pRateOld"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pMarginOld"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pOfferOld"] + "</td>");
                        break;

                    case "S":
                        html.Append("<td class='tdCollApp'>" + dr["cRateOld"] + "</td>");
                        html.Append("<td class='tdCollApp'>" + dr["cMarginOld"] + "</td>");
                        html.Append("<td class='tdCollApp'>" + dr["cOfferOld"] + "</td>");
                        html.Append("<td class='tdPayApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        break;

                    case "R":
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdPayApp'>" + dr["pRateOld"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pMarginOld"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pOfferOld"] + "</td>");
                        break;

                    default:
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        break;
                }
                html.Append("</tr>");
                html.Append("<tr class=\"oddbg\">");
                html.Append("<td align=\"center\"><b>New</b></td>");
                if (dr["factorNew"].ToString() == "M")
                {
                    html.Append("<td align=\"center\">MUL</td>");
                }
                else
                {
                    html.Append("<td align=\"center\">DIV</td>");
                }

                switch (dr["cOperationType"].ToString())
                {
                    case "B":
                        html.Append("<td class='tdCollApp'>" + dr["cRateNew"] + "</td>");
                        html.Append("<td class='tdCollApp'>" + dr["cMarginNew"] + "</td>");
                        html.Append("<td class='tdCollApp'>" + dr["cOfferNew"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pRateNew"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pMarginNew"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pOfferNew"] + "</td>");
                        break;

                    case "S":
                        html.Append("<td class='tdCollApp'>" + dr["cRateNew"] + "</td>");
                        html.Append("<td class='tdCollApp'>" + dr["cMarginNew"] + "</td>");
                        html.Append("<td class='tdCollApp'>" + dr["cOfferNew"] + "</td>");
                        html.Append("<td class='tdPayApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        break;

                    case "R":
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdPayApp'>" + dr["pRateNew"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pMarginNew"] + "</td>");
                        html.Append("<td class='tdPayApp'>" + dr["pOfferNew"] + "</td>");
                        break;

                    default:
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdCollApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        html.Append("<td class='tdPayApp'></td>");
                        break;
                }
                html.Append("</tr>");
            }

            html.Append("</table>");
            rpt_grid.InnerHtml = html.ToString();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("ApproveList.aspx");
            }
            GetStatic.PrintMessage(Page);
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            var dbResult = obj.Approve(GetStatic.GetUser(), chkList, "AG");
            ManageMessage(dbResult);
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            var dbResult = obj.Reject(GetStatic.GetUser(), chkList, "AG");
            ManageMessage(dbResult);
        }

        protected void btnHidden_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
    }
}