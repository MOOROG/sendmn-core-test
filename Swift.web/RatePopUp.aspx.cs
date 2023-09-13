using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Exchange
{
    public partial class RatePopUp : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadAgentInfo();
            LoadTodaysRate();
        }

        private void LoadAgentInfo()
        {
            DateTime today = DateTime.Today;
            StringBuilder sb = new StringBuilder();
            sb.AppendLine(@"<div style='padding: 4px 2px 0 2px; float:left;'> "+GetCompanyImage()+@"</div>
            <div class='topTitle'><strong>TODAY'S EXCHANGE RATE</strong>
	        <br/>
	        <span style = 'font-size:20px !important;'>"+ today.DayOfWeek + " , " + today.ToString("MMMM dd, yyyy") + @"</span>
            </div> ");
            AgentInfoDiv.InnerHtml = sb.ToString();
        }
        public static string GetCompanyImage()
        {
            return "<Img alt=\"Company Logo\" src='../ui/images/logo.png' />";
        }
        private void LoadTodaysRate()
        {
            RemittanceLibrary _remit = new RemittanceLibrary();
            string sql = "EXEC proc_SchedularProcessing @flag = 'Exrate-Display', @user = '" + GetStatic.GetUser() + "'";
            var dt = _remit.ExecuteDataTable(sql);
            StringBuilder sb = new StringBuilder();
            int sno = 1;
            foreach (DataRow dr in dt.Rows)
            {
                sb.AppendLine(@"<table><tbody><tr>
                        <td style = 'width:50%'>
                            <div><img id ='CurrImag' src = '../Images/countryflag/" + dr["pCurrency"].ToString() + @".png' alt = '" + dr["pCurrency"].ToString() + @"' title = '" + dr["pCurrency"].ToString() + @"' border = '0' /></div>
                            <div style = 'font-size:20px' id ='ImageDesc'>" + dr["currencyDesc"].ToString() + @"</div>
                        </td>
                        <td style = 'width:50%'>
                            BUYING <br/>
                            <span id='buying'>" + dr["Unit"].ToString() + " USD "+ @" = " + dr["BuyRate"].ToString()+" " + dr["cCurrency"].ToString() + @" </span>
                            <br/>
                           SELLING <br/>
                            <span id='selling'> 
                            " + dr["Unit"].ToString() + @" " + " USD" + @" = " + dr["SaleRate"].ToString() + @" "+dr["pCurrency"].ToString() + @" </span>
                            <br/>
                            CUSTOMER RATE =  <span id='customerRate'>" + dr["customerRate"].ToString() +@" </span>
                        </td>
                        </tr></tbody></table>");
                AgentBannerDiv.InnerHtml = sb.ToString();
                break;
            }
            sb = new StringBuilder();
            sb.AppendLine(@"<table class='mainTable'><tbody>
                            <tr class='trHeader'>
                            <td style = 'border-radius:10px 0 0 0;'>COUNTRY</td>
                            <td>CURRENCY NAME</td>
				            <td>UNIT</td>
                            <td>BUYING</td>
                            <td style = 'border-radius:0 10px 0 0;'>SELLING</td>            
                            <td style = 'border-radius:0 10px 0 0;'>CUSTOMER RATE</td>            
                            </tr>");
            foreach (DataRow dr in dt.Rows)
            {
                if (sno % 2 == 1)
                    sb.AppendLine("<tr id = 'tr_" + sno.ToString() + "' class='oddStl'>");
                else
                    sb.AppendLine("<tr id = 'tr_" + sno.ToString() + "' class='evenStl'>");

                sb.AppendLine("<td><div align='left'><strong><img src='../Images/countryflag/" + dr["pCurrency"].ToString() + ".png' title='" + dr["countryName"].ToString() + "' alt='" + dr["countryName"].ToString() + "' height='20px' border='0' width='20px'>");
                sb.AppendLine(dr["countryName"].ToString() + "</strong></div></td>");
                sb.AppendLine("<td><div align='left'><strong>" + dr["pCurrency"].ToString() + "</strong></div></td>");
                sb.AppendLine("<td><div align='center'><strong>" + dr["Unit"].ToString()+"</strong></div></td>");
                sb.AppendLine("<td><div align='center'><strong>" + dr["BuyRate"].ToString()+"</strong></div></td>");
                sb.AppendLine("<td><div align='center'><strong>" + dr["SaleRate"].ToString() + "</strong></div></td>");
                sb.AppendLine("<td><div align='center'><strong>" + dr["customerRate"].ToString() + "</strong></div></td>");
                sb.AppendLine("</tr>");
                sno++;
            }
            sb.AppendLine("</tbody></table> ");
            MainTableDiv.InnerHtml = sb.ToString();
            NoOfData.Value = sno.ToString();
        }
    }
}