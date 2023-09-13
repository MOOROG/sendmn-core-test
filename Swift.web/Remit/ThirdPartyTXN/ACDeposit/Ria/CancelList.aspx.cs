using Swift.API.Common.BankDeposit;
using Swift.DAL.BL.ThirdParty.RiaBank;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ThirdPartyTXN.ACDeposit.Ria
{
    public partial class CancelList : System.Web.UI.Page
    {
        private const string ViewFunctionID = "20122900";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private IRiaDao _riaDao = new RiaDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            //LoadGrid();
        }

        protected void btnRiaCancel_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(controlNo.Text) || string.IsNullOrWhiteSpace(cancelReason.Text))
            {
                GetStatic.AlertMessage(this, "All Fields are mandatory!!");
                return;
            }

            DisableButton();
            CancelRiaTxn reqObj = new CancelRiaTxn()
            {
                ProcessId = controlNo.Text,
                //ProviderId = GetStatic.ReadWebConfig("riapartnerid", ""),
                UserName = GetStatic.GetUser(),
                RequestFrom = "core",

                CancelReason = cancelReason.Text,
                PartnerPinNo = controlNo.Text,
            };

            DbResult dbResult = _riaDao.CancelRiaTxn(reqObj);
            GetStatic.AlertMessage(this, dbResult.Msg);
            EnableButton();
        }

        //public void LoadGrid()
        //{
        //    var dt = _riaDao.LoadRiaCancelTxn(GetStatic.GetUser());

        // if (dt == null) { postTxn.Visible = false;

        // GetStatic.AlertMessage(this, "No Transaction Found For This ControlNo"); return; }

        // postTxn.Visible = true; int cols = dt.Columns.Count; int cnt = 0; var totalAmt = 0.00;
        // var str = new StringBuilder("");

        //    str.Append("<table class='table table-responsive table-bordered table-striped'>");
        //    str.Append("<tr>");
        //    str.Append("<th><a href=\"javascript:void(0);\" onClick=\"CheckAll(this)\">√|×</a></th>");
        //    for (int i = 0; i < cols; i++)
        //    {
        //        str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
        //    }
        //    str.Append("</tr>");
        //    if (dt.Rows.Count == 0)
        //    {
        //        str.Append("<tr><td colspan='13' style='color:red' align='center'><b>No Records Found!</td></b></tr>");
        //    }
        //    else
        //    {
        //        foreach (DataRow dr in dt.Rows)
        //        {
        //            str.AppendLine(++cnt % 2 == 1
        //                                    ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
        //                                    : "<tr class=\"evenbg\"  onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
        //            str.Append("<td align=\"center\"><input type='checkbox' id = \"chk_" + dr["Tran No"] + "\" name = \"chkId\" value='" + dr["Control No"].ToString() + "-" + dr["Cancel Reason"].ToString() + "-" + dr["action"].ToString() + "-" + dr["remarks"].ToString() + "' /></td>");
        //            for (int i = 0; i < cols; i++)
        //            {
        //                if (i == 8)
        //                    str.Append("<td style=\"text-align:right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</td>");
        //                else
        //                    str.Append("<td align=\"left\">" + dr[i] + "</td>");
        //            }
        //            str.Append("</tr>");
        //            totalAmt += double.Parse(dr[8].ToString());
        //        }
        //        str.Append("<tr><td colspan=\"9\" style=\"text-align:right\"><b>Total Amount<b></td><td style=\"text-align:right\"><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td><td></td><td></td><td></td><td></td></tr>");
        //    }
        //    str.Append("</table>");
        //    rptGrid.InnerHtml = str.ToString();
        //}

        private void EnableButton()
        {
            btnRiaCancel.Enabled = true;
        }

        private void DisableButton()
        {
            btnRiaCancel.Enabled = false;
        }
    }
}