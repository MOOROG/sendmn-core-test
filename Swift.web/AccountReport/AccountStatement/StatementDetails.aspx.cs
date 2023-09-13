﻿using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web;

namespace Swift.web.AccountReport.AccountStatement {
    public partial class StatementDetails : System.Web.UI.Page {
        private SwiftLibrary _sl = new SwiftLibrary();
        private AccountStatementDAO st = new AccountStatementDAO();
        //private const string ReversalId = "20101110";

        protected void Page_Load(object sender, EventArgs e) {
            //check session
            _sl.CheckSession();
            if (!IsPostBack) {
                PopulateDDL();
                ddlCurrency.Text = GetStatic.ReadQueryString("curr", "");
                hdnRptType.Value = GetStatic.ReadQueryString("type", "a");
                startDate.Text = StartDate();
                endDate.Text = EndDate();
            }

            GenerateReport();
        }

        protected string StartDate() {
            return GetStatic.ReadQueryString("startDate", "");
        }

        protected string EndDate() {
            return GetStatic.ReadQueryString("endDate", "");
        }

        protected string AccountNumber() {
            return GetStatic.ReadQueryString("acNum", "");
        }

        protected string AccountName() {
            return GetStatic.ReadQueryString("acName", "");
        }

        private void PopulateDDL() {
            RemittanceLibrary r = new RemittanceLibrary();
            r.SetDDL(ref ddlCurrency, "EXEC Proc_dropdown_remit @FLAG='Currency'", "val", "Name", "", "Select FCY");
        }

        private void GenerateReport() {
            acNumber.Text = AccountNumber();
            acName.Text = AccountName();
            string curr = "";

            var dt = st.GetACStatement(acNumber.Text, startDate.Text, endDate.Text, ddlCurrency.Text, hdnRptType.Value, GetStatic.GetUser());

            if (dt == null || dt.Rows.Count == 0) {
                tableBody.InnerHtml = "";
                openingBalance.Text = "0";
                drOrCr.Text = "DR";
                closingBalanceAmt.Text = "0 ";
                return;
            }
            if (hdnRptType.Value == "d") {
                GenerateDateWiseStmt(dt);
                return;
            }
            var sb = new StringBuilder("");

            sb.AppendLine("<table class=\"table table-striped table-bordered\" width=\"100%\" cellspacing=\"0\" class=\"TBLReport\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap'>SN</th>");
            sb.AppendLine("<th nowrap='nowrap'>Tran Date</th>");
            sb.AppendLine("<th nowrap='nowrap'>Particulars</th>");
            //if (!string.IsNullOrWhiteSpace(ddlCurrency.Text))
            //{
            sb.AppendLine("<th nowrap='nowrap'>FCY</th>");
            sb.AppendLine("<th nowrap='nowrap'>FCY Amount</th>");
            sb.AppendLine("<th nowrap='nowrap'>FCY Closing</th>");
            sb.AppendLine("<th nowrap='nowrap'>DR/CR</th>");
            //}

            sb.AppendLine("<th nowrap='nowrap'>" + GetStatic.ReadWebConfig("currencyMN", "") + " Amount</th>");
            sb.AppendLine("<th nowrap='nowrap'>" + GetStatic.ReadWebConfig("currencyMN", "") + " Closing</th>");
            sb.AppendLine("<th nowrap='nowrap'>DR/CR</th>");
            //if (_sl.HasRight(ReversalId))
            //{
            //    sb.AppendLine("<th nowrap='nowrap'>Reversal</th>");
            //}

            sb.AppendLine("</tr>");

            double BAlance = 0, OpenBalnce = 0, fcyOpening = 0, crAmt = 0, drAmt = 0;
            int sn = 1, drCount = 0, crCount = 0;
            foreach (DataRow item in dt.Rows) {
                if (item["tran_particular"].ToString() == "Balance Brought Forward") {
                    sn = 0;
                    if (item["fcy_Curr"] == null || item["fcy_Curr"].ToString().ToLower() == "mnt") {
                        OpenBalnce = GetStatic.ParseDouble(item["tran_amt"].ToString());
                    } else {
                        OpenBalnce = GetStatic.ParseDouble(item["usd_amt"].ToString());
                    }
                    fcyOpening = GetStatic.ParseDouble(item["usd_amt"].ToString());
                    BAlance = GetStatic.ParseDouble(item["tran_amt"].ToString());
                } else {
                    BAlance += GetStatic.ParseDouble(item["tran_amt"].ToString());
                    fcyOpening += GetStatic.ParseDouble(item["usd_amt"].ToString());
                }
                sb.AppendLine("<tr>");

                curr = item["fcy_Curr"].ToString();

                if (item["tran_particular"].ToString() != "Balance Brought Forward") {
                    if (item["part_tran_type"].ToString().ToLower() == "cr") {
                        crCount++;
                        if (item["fcy_Curr"] == null || item["fcy_Curr"].ToString().ToLower() == "mnt") {
                            crAmt += GetStatic.ParseDouble(item["tran_amt"].ToString());
                        } else {
                            crAmt += GetStatic.ParseDouble(item["usd_amt"].ToString());
                        }

                    } else {
                        drCount++;
                        if (item["fcy_Curr"] == null || item["fcy_Curr"].ToString().ToLower() == "mnt") {
                            drAmt += GetStatic.ParseDouble(item["tran_amt"].ToString());
                        } else {
                            drAmt += GetStatic.ParseDouble(item["usd_amt"].ToString());
                        }
                    }
                }


                string drLink = "<a href='userreportResultSingle.aspx?company_id=1&vouchertype=" + item["tran_type"].ToString();
                drLink += "&type=trannumber&trn_date=" + item["tran_date"].ToString() + "&tran_num=" + item["ref_num"].ToString() + "' title='Transaction info' >";
                drLink += GetStatic.ShowDecimal_Account(item["tran_amt"].ToString()) + "</a>";

                sb.AppendLine("<td  >" + (sn > 0 ? sn.ToString() : "") + " </td>");
                sb.AppendLine("<td nowrap align='center' >" + (item["tran_date"].ToString() == "1900.01.01" ? "&nbsp;" : item["tran_date"]) + " </td>");
                sb.AppendLine("<td  >" + item["tran_particular"] + " </td>");
                //if (!string.IsNullOrWhiteSpace(ddlCurrency.Text))
                //{
                sb.AppendLine("<td  >" + item["fcy_Curr"] + " </td>");
                sb.AppendLine("<td  >" + GetStatic.ShowDecimal_Account(item["usd_amt"].ToString()) + " </td>");
                sb.AppendLine("<td  >" + GetStatic.ShowDecimal_Account(fcyOpening.ToString()) + " </td>");
                sb.AppendLine("<td  >" + item["part_tran_type"] + " </td>");
                //}
                sb.AppendLine("<td  >" + (item["tran_particular"].ToString() == "Balance Brought Forward" ? GetStatic.ShowDecimal_Account(item["tran_amt"].ToString()) : drLink) + " </td>");
                sb.AppendLine("<td  >" + GetStatic.ShowDecimal_Account(BAlance.ToString()) + " </td>");
                sb.AppendLine("<td  >" + (BAlance > 0 ? "CR" : "DR") + " </td>");
                //if (_sl.HasRight(ReversalId) && sn > 0)
                //{
                //    drLink = "<a class='btn btn-danger' href='userreportResultSingle.aspx?r=Y&company_id=1&vouchertype=" + item["tran_type"].ToString();
                //    drLink += "&type=trannumber&trn_date=" + item["tran_date"].ToString() + "&tran_num=" + item["ref_num"].ToString() + "' title='Transaction info' >Reverse</a>";

                //    sb.AppendLine("<td  >" + drLink + " </td>");
                //}
                sb.AppendLine("</tr>");
                sn++;
            }

            if (GetStatic.ReadQueryString("isDownload", "") == "y") {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td>Opening Balance: </td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal_Account(OpenBalnce.ToString()) + "</td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("</tr>");

                sb.AppendLine("<tr>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td>Total DR:(" + drCount.ToString() + ")  </td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal_Account(drAmt.ToString()) + "</td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("</tr>");

                sb.AppendLine("<tr>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td>Total CR:(" + crCount.ToString() + ")  </td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal_Account(crAmt.ToString()) + "</td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("</tr>");

                sb.AppendLine("<tr>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td>Closing Balance: (" + (BAlance > 0 ? "CR" : "DR") + ")  </td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal_Account((BAlance > 0 ? BAlance * -1 : BAlance).ToString()) + "</td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("</tr>");

                sb.AppendLine("</table>");

                DataTable tbl = GetStatic.ConvertHTMLTableToDataSet(sb.ToString());
                GetStatic.DataTable2ExcelDownload(ref tbl, "AccountStatement");
            } else {
                sb.AppendLine("</table>");
            }
            totalDr.Text = GetStatic.ShowDecimal_Account(drAmt.ToString());
            totalCr.Text = GetStatic.ShowDecimal_Account(crAmt.ToString());
            drCount1.Text = drCount.ToString();
            crCount1.Text = crCount.ToString();

            tableBody.InnerHtml = sb.ToString();
            openingBalance.Text = GetStatic.ShowDecimal_Account(OpenBalnce.ToString());
            drOrCr.Text = (BAlance > 0 ? "CR" : "DR");

            if (curr == null || curr.ToLower() == "mnt") {
                closingBalanceAmt.Text = GetStatic.ShowDecimal_Account((BAlance > 0 ? BAlance * -1 : BAlance).ToString());
            } else {
                closingBalanceAmt.Text = GetStatic.ShowDecimal_Account((fcyOpening > 0 ? fcyOpening * -1 : fcyOpening).ToString());
            }
        }

        private void GenerateDateWiseStmt(DataTable dt) {
            var sb = new StringBuilder("");

            sb.AppendLine("  <div class=\"table-responsive\"><table class=\"table table-striped table-bordered\" width=\"100%\" cellspacing=\"0\" class=\"TBLReport\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap'>SN</th>");
            sb.AppendLine("<th nowrap='nowrap'>Tran Date</th>");
            sb.AppendLine("<th nowrap='nowrap'>Particulars</th>");
            sb.AppendLine("<th nowrap='nowrap'>FCY</th>");
            sb.AppendLine("<th nowrap='nowrap'>FCY Amount</th>");
            sb.AppendLine("<th nowrap='nowrap'>FCY Closing</th>");
            sb.AppendLine("<th nowrap='nowrap'>" + GetStatic.ReadWebConfig("currencyMN", "") + " Amount</th>");
            sb.AppendLine("<th nowrap='nowrap'>" + GetStatic.ReadWebConfig("currencyMN", "") + " Closing</th>");
            sb.AppendLine("</tr>");

            double BAlance = 0, OpenBalnce = 0, fcyOpening = 0;
            int sn = 1;
            foreach (DataRow item in dt.Rows) {
                if (item["tran_particular"].ToString() == "Balance Brought Forward") {
                    sn = 0;
                    OpenBalnce = GetStatic.ParseDouble(item["tran_amt"].ToString());
                    fcyOpening = GetStatic.ParseDouble(item["usd_amt"].ToString());
                    BAlance = OpenBalnce;
                } else {
                    BAlance += GetStatic.ParseDouble(item["tran_amt"].ToString());
                    fcyOpening += GetStatic.ParseDouble(item["usd_amt"].ToString());
                }
                sb.AppendLine("<tr>");

                string drLink = "<a href='StatementDetails.aspx?acNum=" + item["acc_num"].ToString();
                drLink += "&startDate=" + item["tran_date"].ToString() + "&endDate=" + item["tran_date"].ToString() + "' title='Transaction info' >";
                drLink += GetStatic.ShowDecimal_Account(item["tran_amt"].ToString()) + "</a>";

                sb.AppendLine("<td  >" + (sn > 0 ? sn.ToString() : "") + " </td>");
                sb.AppendLine("<td nowrap align='center' >" + (item["tran_date"].ToString() == "1900.01.01" ? "&nbsp;" : item["tran_date"]) + " </td>");
                sb.AppendLine("<td  >" + item["tran_particular"] + " </td>");
                //if (!string.IsNullOrWhiteSpace(ddlCurrency.Text))
                //{
                sb.AppendLine("<td  >" + item["fcy_Curr"].ToString() + " </td>");
                sb.AppendLine("<td  >" + GetStatic.ShowDecimal_Account(item["usd_amt"].ToString()) + " </td>");
                sb.AppendLine("<td  >" + GetStatic.ShowDecimal_Account(fcyOpening.ToString()) + " </td>");
                //}
                sb.AppendLine("<td  >" + (item["tran_particular"].ToString() == "Balance Brought Forward" ? GetStatic.ShowDecimal_Account(item["tran_amt"].ToString()) : drLink) + " </td>");
                sb.AppendLine("<td  >" + GetStatic.ShowDecimal_Account(BAlance.ToString()) + " </td>");
                sb.AppendLine("</tr>");
                sn++;
            }

            sb.AppendLine("</table></div>");

            tableBody.InnerHtml = sb.ToString();
            openingBalance.Text = GetStatic.ShowDecimal_Account(OpenBalnce.ToString());
            closingBalanceAmt.Text = GetStatic.ShowDecimal_Account((BAlance > 0 ? BAlance * -1 : BAlance).ToString());
        }

        protected void goBtn_Click(object sender, EventArgs e) {
            GenerateReport();
        }

        protected void buttonPdf_Click(object sender, EventArgs e) {
            GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }
    }
}