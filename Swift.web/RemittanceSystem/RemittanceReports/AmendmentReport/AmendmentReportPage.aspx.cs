using Swift.DAL.Remittance.Amendment;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.RemittanceSystem.RemittanceReports.AmendmentReport
{
    public partial class AmendmentReportPage : System.Web.UI.Page
    {
        private readonly AmendmentDao _ado = new AmendmentDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetDetailReportNew();
            }
        }

        private void GetDetailReportNew()
        {
            DataSet ds = _ado.GetAmendmentReport(GetStatic.GetUser(), GetCustomerId(), GetRowId(), GetChangeType(), GetReceiverId());

            if (ds == null || ds.Tables.Count == 0)
            {
                return;
            }

            DataTable columnList = ds.Tables[0];
            DataTable dataList = ds.Tables[1];

            customerName.InnerText = dataList.Rows[0]["customerName"].ToString();
            customerId.InnerText = dataList.Rows[0]["customerId"].ToString();

            StringBuilder sb = new StringBuilder();
            
            date.InnerText = GetmodifiedDate();
            string changeType = GetChangeType();

            if (changeType.ToLower() == "transaction")
            {
                customerDiv.Visible = false;
                customerHeadingDiv.Visible = false;
                receiverHeadingDiv.Visible = false;
                controlNo.InnerText = dataList.Rows[0]["CONTROLNUMBER"].ToString();

                for (int i = 0; i < columnList.Columns.Count; i++)
                {
                    var data = GetDisplayResultValue(columnList.Rows[0][i].ToString().Split('_')[0], dataList);

                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td>" + columnList.Rows[0][i].ToString().Split('_')[1] + "</td>");
                    sb.AppendLine("<td>" + data[0] + "</td>");
                    sb.AppendLine("<td>" + data[1] + "</td>");
                    sb.AppendLine("</tr>");
                }
                receiverInfo.InnerHtml = sb.ToString();
            }
            else if (changeType.ToLower() == "receiver")
            {
                customerDiv.Visible = false;
                customerHeadingDiv.Visible = false;
                TransactionHeadingDiv.Visible = false;

                for (int i = 0; i < columnList.Columns.Count; i++)
                {
                    var data = GetDisplayResultValue(columnList.Rows[0][i].ToString().Split('_')[0], dataList);

                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td>" + columnList.Rows[0][i].ToString().Split('_')[1] + "</td>");
                    sb.AppendLine("<td>" + data[0] + "</td>");
                    sb.AppendLine("<td>" + data[1] + "</td>");
                    sb.AppendLine("</tr>");
                }
                receiverInfo.InnerHtml = sb.ToString();
            }
            else if (changeType.ToLower() == "customer")
            {
                receiverDiv.Visible = false;
                receiverHeadingDiv.Visible = false;
                TransactionHeadingDiv.Visible = false;

                for (int i = 0; i < columnList.Columns.Count; i++)
                {
                    var data = GetDisplayResultValue(columnList.Rows[0][i].ToString().Split('_')[0], dataList);

                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td>" + columnList.Rows[0][i].ToString().Split('_')[1] + "</td>");
                    sb.AppendLine("<td>" + data[0] + "</td>");
                    sb.AppendLine("<td>" + data[1] + "</td>");
                    sb.AppendLine("</tr>");
                }
                custInfo.InnerHtml = sb.ToString();
            }
        }

        private string[] GetDisplayResultValue(string columnName, DataTable dataList)
        {
            string[] retValue = new string[2];
            if (dataList.Select().ToList().Exists(row => row["COLUMNNAME"].ToString().ToLower() == columnName.ToLower()))
            {
                foreach (DataRow item in dataList.Rows)
                {
                    if (item["COLUMNNAME"].ToString().ToLower() == columnName.ToLower())
                    {
                        retValue[0] = item["OLDVALUE"].ToString() == "" ? "-" : item["OLDVALUE"].ToString();
                        retValue[1] = item["NEWVALUE"].ToString() == "" ? "-" : item["NEWVALUE"].ToString();
                    }
                }
            }
            else
            {
                retValue[0] = dataList.Rows[0][columnName].ToString() == "" ? "-" : dataList.Rows[0][columnName].ToString();
                retValue[1] = "-";
            }

            return retValue;
        }

        private void GetDetailReport()
        {
            DataSet Result = _ado.GetAmendmentReport(GetStatic.GetUser(), GetCustomerId(), GetRowId(), GetChangeType(),GetReceiverId());
            
            if (Result == null || Result.Tables.Count == 0)
            {
                return;
            }

            StringBuilder sb = new StringBuilder();
            if(Result.Tables.Count > 1)
            {
                customerName.InnerText = Result.Tables[1].Rows[0]["fullname"].ToString();
                customerId.InnerText = Result.Tables[1].Rows[0]["customerId"].ToString();
            }
         
            date.InnerText = GetmodifiedDate();
            string ChangeType = GetChangeType();
            if (ChangeType.ToLower() == "transaction") {
                customerDiv.Visible = false;
                customerHeadingDiv.Visible = false;
                receiverHeadingDiv.Visible = false;
                if (Result.Tables[0].Rows.Count == 0)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td class=\"tg-0lax\"></td>");
                    sb.AppendLine("<td class=\"tg-0lax\">No Records Found</td>");
                    sb.AppendLine("<td class=\"tg-0lax\"></td>");
                    sb.AppendLine("</tr>");
                }
                else
                {
                    controlNo.InnerText = Result.Tables[0].Rows[0]["CONTROLNUMBER"].ToString();
                    foreach (DataRow items in Result.Tables[0].Rows)
                    {
                        sb.AppendLine("<tr>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["columnName"].ToString() + "</td>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["oldValue"].ToString() + "</td>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["newvalue"].ToString() + "</td>");
                        sb.AppendLine("</tr>");
                    }
                }
                receiverInfo.InnerHtml = sb.ToString();
            }
            else if (ChangeType.ToLower() == "receiver") {
                customerDiv.Visible = false;
                customerHeadingDiv.Visible = false;
                TransactionHeadingDiv.Visible = false;
                if (Result.Tables[0].Rows.Count == 0)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td class=\"tg-0lax\"></td>");
                    sb.AppendLine("<td class=\"tg-0lax\">No records found</td>");
                    sb.AppendLine("<td class=\"tg-0lax\"></td>");
                    sb.AppendLine("</tr>");
                }
                else
                {
                    //controlNo.InnerText = Result.Tables[0].Rows[0]["tranId"].ToString();
                    foreach (DataRow items in Result.Tables[0].Rows)
                    {
                        sb.AppendLine("<tr>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["columnName"].ToString() + "</td>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["oldValue"].ToString() + "</td>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["newvalue"].ToString() + "</td>");
                        sb.AppendLine("</tr>");
                    }
                }
                receiverInfo.InnerHtml = sb.ToString();
            }
            else if (ChangeType.ToLower() == "customer")
            {
                receiverDiv.Visible = false;
                receiverHeadingDiv.Visible = false;
                TransactionHeadingDiv.Visible = false;
                if (Result.Tables[0].Rows.Count == 0)
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td class=\"tg-0lax\"></td>");
                    sb.AppendLine("<td class=\"tg-0lax\">No records found</td>");
                    sb.AppendLine("<td class=\"tg-0lax\"></td>");
                    sb.AppendLine("</tr>");
                }
                else
                {
                    //controlNo.InnerText = Result.Tables[0].Rows[0]["tranId"].ToString();
                    foreach (DataRow items in Result.Tables[0].Rows)
                    {
                        sb.AppendLine("<tr>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["columnName"].ToString() + "</td>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["oldValue"].ToString() + "</td>");
                        sb.AppendLine("<td class=\"tg-0lax\">" + items["newvalue"].ToString() + "</td>");
                        sb.AppendLine("</tr>");
                    }
                }
                custInfo.InnerHtml = sb.ToString();
            }
        }
        private string GetCustomerId()
        {
            return GetStatic.ReadQueryString("customerId", "");
        }
        private string GetRowId()
        {
            return GetStatic.ReadQueryString("RowId", "");
        }
        private string GetmodifiedDate()
        {
            return GetStatic.ReadQueryString("modifiedDate", "");
        }
        private string GetChangeType()
        {
            return GetStatic.ReadQueryString("changeType", "");
        }
        private string GetReceiverId()
        {
            return GetStatic.ReadQueryString("receiverId", "");
        }
    }
}