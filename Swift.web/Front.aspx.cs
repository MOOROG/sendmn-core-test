using iText.Layout;
using Newtonsoft.Json;
using OpenQA.Selenium.Remote;
using Org.BouncyCastle.Bcpg.OpenPgp;
using Swift.API.Common;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace Swift.web
{
    public partial class Front : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();
        protected List<int> YourDataFromCodeBehind;
        protected List<string> dataCountries;
        protected List<double> dataSCharge;
        protected List<string> dataCountriesUnique = new List<string>();
        protected List<double> dataSChargeUnique = new List<double>();
        protected List<string> searchListMonth = new List<string>();
        protected List<string> searchListYear = new List<string>();
        protected List<string> searchListAgent = new List<string>();
        protected List<string> searchListCountry = new List<string>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "timeline", $"var timeline=false;", true);
                ViewState["timeline"] = "false";
                // Initialize the variable and store it in ViewState
                ViewState["year"] = "2022";
                ViewState["agent"] = "Ria Agent,GME-Korea Agent,SendMN Online Branch,IME Agent,Gmoney Agent,Hanpass Agent,TerraPay Agent,Finshot Agent,Tranglo Agent,Monex Agent";
                ViewState["country"] = "United Arab Emirates,China CU,Malta, Mongolia,Turkey, Portugal,Greece,Philippines,United States,Sweden,Slovakia,Latvia,United Kingdom,New Zealand,Albania,Israel,Lithuania,Croatia,Vietnam,Japan,South Korea,Netherlands,Serbia,Hong Kong,Norway,Switzerland,South Korea GM,Thailand,Finland,Pakistan,Luxembourg,Italy,Estonia,Ireland,Czech Republic,Canada,Ukraine,South Korea HP,Malaysia,Slovenia,Austria,Spain,Bulgaria, Russian Federation, Hungary, Romania, Belgium, 142, Australia, France, Bosnia and Herzegovina, Poland, Denmark, Germany, China, India, Montenegro";
                ViewState["currency"] = "MNT";
                ViewState["month"] = "1,2,3,4,5,6,7,8,9,10,11,12";
                ViewState["tranType"] = "O";
                LoadDashboard();
            }
            //switch (MethodName)
            //{
            //    case "Messages":
            //        PopulateMessageDetail();
            //        break;

            //    default:
            //        break;
            //}

            //sl.CheckViewState();
            //if (!IsPostBack)
            //{
            //    //Load_TransactionCount();
            //    PopulateMessages();
            //}
        }
        public string ToMillionString(double d)
        {
            double totalAmountsText = d / 1000000; // Convert to millions
            return totalAmountsText.ToString("0.##") + "M";
        }
        public double ToMillion(double d)
        {
            double totalAmountsText = d / 1000000; // Convert to millions
            return double.Parse(totalAmountsText.ToString("0.##"));
        }
        private double GetTotalCountry(string country)
        {
            double totalValue = 0.0;
            for (int i = dataCountries.Count - 1; i >= 0; i--)
            {
                if (dataCountries[i].ToLower().Contains(country))
                {
                    totalValue += dataSCharge[i];
                    dataSCharge.RemoveAt(i);
                    dataCountries.RemoveAt(i);
                }
                //else
                //{
                //    dataCountriesUnique.Add(dataCountries[i]);
                //    dataSChargeUnique.Add(dataSCharge[i]);
                //}
            }
            return Math.Round(totalValue, 2);
        }

        private bool DataExists(DataTable dataTable, int rowIndex, int colCount)
        {
            bool retVal = false;
            rowIndex = (rowIndex.Equals(0)) ? 1 : rowIndex;
            for (int i = rowIndex; i < dataTable.Rows.Count; i++)
            {
                if (dataTable.Rows[i][colCount].ToString() != "0")
                {
                    retVal = true;
                }
            }
            return retVal;
        }


        private void PopulateMessageDetail()
        {
            string msgId = Request.Form["MessageId"];
            var obj = new MessageSettingDao();
            DataRow dr = obj.GetNewsFeederMessage(msgId);
            if (dr == null)
            {
                return;
            }
            MessageData _data = new MessageData();

            _data.CreatedBy = dr["createdBy"].ToString();
            _data.CreatedDate = dr["createdDate"].ToString();
            _data.Message = dr["newsFeederMsg"].ToString();

            var json = new JavaScriptSerializer().Serialize(_data);
            JsonSerialize(json);
        }

        private void JsonSerialize<T>(T obk)
        {
            JavaScriptSerializer jsonData = new JavaScriptSerializer();
            string jsonString = jsonData.Serialize(obk);
            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.Write(jsonString);
            HttpContext.Current.Response.End();
        }

        public class MessageData
        {
            public string CreatedBy { get; set; }
            public string CreatedDate { get; set; }
            public string Message { get; set; }
        }

        protected String GetDate()
        {
            return DateTime.Now.ToString("yyyy-MM-dd");
        }

        protected void Load_TransactionCount()
        {
            var obj = new MessageSettingDao();
            var ds = obj.Get_TransactionCount(GetStatic.GetUser());
            //divPopulateTxnCount.Visible = false;
            //TxnWiseStatus.Visible = false;

            if (null == ds)
            {
                return;
            }
            if (ds.Tables.Count == 0)
            {
                return;
            }

            var dr = ds.Tables[0].Rows[0];
            //iCancel.Text = dr["iCancel"].ToString();
            //iSend.Text = dr["iSend"].ToString();
            //iPaid.Text = dr["intPaidCount"].ToString();
            //iCode.Text = dr["iCode"].ToString();
            //balanceId.Text = dr["balance"].ToString();

            //divPopulateTxnCount.Visible = true;
            //TxnWiseStatus.Visible = true;

            var dt = ds.Tables[1];
            int sn = 0;
            var sb = "";
            sb += "<table class='table table-responsive table-bordered'>";
            sb += "<tr>";
            sb += "<th>S.N</th>";
            sb += "<th>NO OF TXN</th>";
            sb += "<th>STATUS</th>";
            sb += "</tr>";
            foreach (DataRow item in dt.Rows)
            {
                sn++;
                sb += "<tr>";
                sb += "<td>" + sn + "</td>";
                sb += "<td><a onclick=\"ShowReport('" + item["tranStatus"] + "')\">" + item["TxnNo"] + "</a></td>";
                sb += "<td>" + item["tranStatus"] + "</td>";
                sb += "</tr>";
            }
            sb += "</table>";
            if (dt.Rows.Count > 0)
            {
                //TxnWiseStatus.InnerHtml = sb;
            }

            if (ds.Tables[2].Rows.Count > 0)
            {
                var dtt = ds.Tables[2].Rows[0];
                //diff.Text = "Хэцүү: " + dtt["iDifficult"].ToString() + "&nbsp;&nbsp;";
                //diff.ForeColor = Color.Red;
                //norm.Text = "Хэвийн: " + dtt["iNormal"].ToString() + "&nbsp;&nbsp;";
                //norm.ForeColor = Color.Yellow;
                //easy.Text = "Хялбар: " + dtt["iEasy"].ToString() + "&nbsp;&nbsp;";
                //easy.ForeColor = Color.Aquamarine;
                List<int> listInt = new List<int>();
                listInt.Add(Convert.ToInt32(dtt["iDifficult"]));
                listInt.Add(Convert.ToInt32(dtt["iNormal"]));
                listInt.Add(Convert.ToInt32(dtt["iEasy"]));
                double aveRate = listInt.Max();
                if (dtt["iAverage"] != System.DBNull.Value)
                {
                    //appreview.Text = "Дундаж : " + dtt["iAverage"].ToString();
                    if (Convert.ToDouble(dtt["iAverage"]) > 0 && Convert.ToDouble(dtt["iAverage"]) < 1.5)
                    {
                        //emoji.InnerHtml = "<i class=\"fa fa-frown-o\"></i>";
                    }
                    else if (Convert.ToDouble(dtt["iAverage"]) >= 1.5 && Convert.ToDouble(dtt["iAverage"]) < 2.5)
                    {
                        //emoji.InnerHtml = "<i class=\"fa fa-meh-o\"></i>";
                    }
                    else if (Convert.ToDouble(dtt["iAverage"]) >= 2.5)
                    {
                        //emoji.InnerHtml = "<i class=\"fa fa-smile-o\"></i>";
                    }
                }
            }
        }
        protected void LoadDashboard()
        {
            JsonResponse jsonResponse = new JsonResponse();
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            TransactionDataService serviceObj = new TransactionDataService();
            TransactionDataRequest transactionDataRequest = new TransactionDataRequest
            {
                flag = "all",
                tranType = ViewState["tranType"].ToString(),
                year = ViewState["year"].ToString(),
                month = ViewState["month"].ToString(),
                country = ViewState["country"].ToString(),
                agent = ViewState["agent"].ToString(),
                currency = ViewState["currency"].ToString(),
            };
            jsonResponse = serviceObj.GetTransactionData(transactionDataRequest);
            var transactionDataResponses = (List<TransactionDataResponse>)jsonResponse.Data;

            transactionDataRequest.flag = "agentList";
            jsonResponse = serviceObj.GetTransactionData(transactionDataRequest);
            var agentDataResponses = (List<AgentDataResponse>)jsonResponse.Data;

            transactionDataRequest.flag = "currency";
            jsonResponse = serviceObj.GetTransactionData(transactionDataRequest);
            var transactionCurrencyDataResponses = (List<TransactionCurrencyDataResponse>)jsonResponse.Data;
            transactionDataRequest.flag = "days";
            jsonResponse = serviceObj.GetTransactionData(transactionDataRequest);
            var transactionDaysDataResponses = (List<TransactionDaysDataResponse>)jsonResponse.Data;

            //if (ViewState["currency"].ToString() == "USD")
            //{
            //    foreach (var response in transactionDataResponses)
            //    {
            //        response.total = (double.Parse(response.total) * 2).ToString();
            //        response.sCharge = (double.Parse(response.sCharge) * 2).ToString();
            //    }
            //    foreach (var response in transactionDaysDataResponses)
            //    {
            //        response.totalMNT = (double.Parse(response.totalMNT) * 2).ToString();
            //    }
            //}

            transactionDataRequest.flag = "countryList";
            jsonResponse = serviceObj.GetTransactionData(transactionDataRequest);
            var countryDataResponses = (List<CountryDataResponse>)jsonResponse.Data;
            var cd = countryDataResponses.Select(c => c.country).ToList();
            cd.RemoveAll(item => item == null);
            dropdownCountry.DataSource = cd;
            dropdownCountry.DataBind();
            var al = agentDataResponses.Select(agent => agent.agentName).ToList();
            dropdownAgent.DataSource = al;
            dropdownAgent.DataBind();

            string input = ViewState["month"].ToString();
            string[] parts = input.Split(',');
            for (int i = 0; i < dropdownMonth.Items.Count; i++)
            {
                if (parts.Contains(dropdownMonth.Items[i].Value))
                {
                    dropdownMonth.Items[i].Selected = true;
                }
            }
            input = ViewState["year"].ToString();
            parts = input.Split(',');
            for (int i = 0; i < dropdownYear.Items.Count; i++)
            {
                if (parts.Contains(dropdownYear.Items[i].Value))
                {
                    dropdownYear.Items[i].Selected = true;
                }
            }
            input = ViewState["agent"].ToString();
            parts = input.Split(',');
            for (int i = 0; i < dropdownAgent.Items.Count; i++)
            {
                if (parts.Contains(dropdownAgent.Items[i].Value))
                {
                    dropdownAgent.Items[i].Selected = true;
                }
            }
            input = ViewState["country"].ToString();
            parts = input.Split(',');
            for (int i = 0; i < dropdownCountry.Items.Count; i++)
            {
                if (parts.Contains(dropdownCountry.Items[i].Value))
                {
                    dropdownCountry.Items[i].Selected = true;
                }
            }

            double totalSCharge = 0.0;
            foreach (TransactionDataResponse response in transactionDataResponses)
            {
                if (double.TryParse(response.sCharge, out double sChargeValue))
                {
                    totalSCharge += sChargeValue;
                }
                else
                {
                    Console.WriteLine("Invalid sCharge value: " + response.sCharge);
                }
            }

            Console.WriteLine("Total sCharge: " + totalSCharge);
            double totalAmounts = 0.0;
            int rowCount = 0;
            Dictionary<string, double> agentData = new Dictionary<string, double>();
            foreach (TransactionDataResponse response in transactionDataResponses)
            {
                if (!agentData.ContainsKey(response.agent))
                {
                    agentData.Add(response.agent, 0.0);
                }
                if (double.TryParse(response.total, out double amountValue))
                {
                    totalAmounts += amountValue;
                }
                else
                {
                    Console.WriteLine("Invalid sCharge value: " + response.total);
                }
                rowCount += int.Parse(response.groupRowCount);
            }
            Console.WriteLine("Total sCharge: " + totalAmounts);

            volumeAmount.Text = rowCount.ToString();

            double totalAmountsText = totalAmounts / 1000000; // Convert to millions
            totalAmount.Text = totalAmountsText.ToString("0.##") + "M";

            double totalSChargeText = totalSCharge / 1000000; // Convert to millions
            commissionAmount.Text = totalSChargeText.ToString("0.##") + "M";

            profitAmount.Text = (totalSChargeText / totalAmountsText).ToString("N2") + "%";
            //totalAmount.Text = totalAmounts.ToString();
            //commissionAmount.Text = totalSCharge.ToString();

            dataCountries = transactionDataResponses.Select(data => data.country).ToList();
            dataSCharge = transactionDataResponses.Select(data => ToMillion(double.TryParse(data.total, out double result) ? result : 0.0)).ToList();
            var koreaTotal = GetTotalCountry("south korea");
            var USTotal = GetTotalCountry("united states");

            dataCountries.Add("South Korea");
            dataSCharge.Add(koreaTotal);
            dataCountries.Add("United States");
            dataSCharge.Add(USTotal);

            //var USTotal = GetTotalCountry("united states");
            //dataCountriesUnique.Add("United States");
            //dataSChargeUnique.Add(USTotal);
            string countriesJson = serializer.Serialize(dataCountries);
            string sChargeJson = serializer.Serialize(dataSCharge);

            var MethodName = Request.Form["MethodName"];
            YourDataFromCodeBehind = new List<int> { 300, 400, 350, 500, 490, 600, 700, 910, 1250 };
            string json = serializer.Serialize(YourDataFromCodeBehind);
            List<string> yearListUnique = transactionDataResponses.Select(data => data.tranYear).Distinct().ToList();

            List<TransactionYearMonth> transactionYearMonths = new List<TransactionYearMonth>();
            int startYear = Int32.Parse(transactionDataRequest.year.Split(',')[0]);
            int prevYear = startYear;
            TransactionYearMonth yearMonth = new TransactionYearMonth();
            yearMonth.year = startYear.ToString();
            yearMonth.month = new List<double> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
            foreach (var response in transactionDataResponses)
            {
                agentData[response.agent] += double.Parse(response.total);
                if (Int32.Parse(response.tranYear) != prevYear)
                {
                    TransactionYearMonth copiedList = new TransactionYearMonth()
                    {
                        year = yearMonth.year,
                        month = yearMonth.month,
                    };
                    transactionYearMonths.Add(copiedList);
                    yearMonth.year = response.tranYear;
                    yearMonth.month = new List<double> { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
                    yearMonth.month[Int32.Parse(response.tranMonth) - 1] += double.Parse(response.total);
                    prevYear = Int32.Parse(response.tranYear);
                }
                else
                {
                    yearMonth.month[Int32.Parse(response.tranMonth) - 1] += double.Parse(response.total);
                }
            }
            transactionYearMonths.Add(yearMonth);
            List<int> dataTranMonths = transactionDataResponses.Select(data => Int32.TryParse(data.tranMonth, out int result) ? result : 0).ToList();
            List<List<double>> monthList = transactionYearMonths.Select(data => data.month).ToList();
            List<string> yearList = transactionYearMonths.Select(data => data.year).ToList();
            string options1string = "";
            string options4string = "";
            string options5string = "";
            Dictionary<string, string> dataTranDays = transactionDaysDataResponses.ToDictionary(data => data.tranDay, data => data.totalMNT);

            for (int i = 0; i < 30; i++)
            {
                string template = @"
                    {
                        x: '{name}',
                        y: '{data}'
                    },
                ";
                template = template.Replace("{name}", i.ToString());
                if (dataTranDays.ContainsKey(i.ToString()))
                {
                    template = template.Replace("{data}", ToMillionString(double.Parse(dataTranDays[i.ToString()].Replace(",", ""))));
                }
                else
                {
                    template = template.Replace("{data}", "0.0");
                }
                options1string += template;
            }

            for (int i = 0; i < yearList.Count; i++)
            {

                List<string> quotedDoubles = monthList[i].Select(d => $"'{ToMillionString(d)}'").ToList();
                string joinedString = string.Join(",", quotedDoubles);
                string template = @"
                    {
                        name: '{name}',
                        data: [{data}]
                    },
                ";
                template = template.Replace("{name}", yearList[i]);
                template = template.Replace("{data}", joinedString);
                options4string += template;
            }
            foreach (KeyValuePair<string, double> kvp in agentData)
            {
                string key = kvp.Key;
                double val = kvp.Value;

                string template = @"
                    {
                        x: '{name}',
                        y: '{data}'
                    },
                ";
                template = template.Replace("{name}", key);
                template = template.Replace("{data}", ToMillionString(val));
                options5string += template;
            }
            string category = serializer.Serialize(yearList);
            string value = serializer.Serialize(monthList);
            string test = "RUB";
            string options1 = $@"
                var options1 = {{
                    chart: {{
                        height: '300px',
                        width: '100%',
                        type: 'bar',
                        foreColor: '#ffffff'
                    }},
                    series: [{{
                        data: [ {options1string}]
                    }}],
                    tooltip: {{
                        y: {{
                            formatter: function (val) {{
                                return '₮ ' + val + ' Millions';
                            }}
                        }}
                    }}
                }};
            ";
            string options2 = $@"
                var options2 = {{
                    chart: {{
                        height: '250px',
                        type: 'donut',
                        foreColor: '#ffffff'
                    }},
                    series: [44, 55, 13, 33, 100],
                    labels: ['USD', 'MNT', 'KRW', 'EUR', '{test}']
                }};
            ";
            //options2 = options2.Replace("{0}", test);
            string options4 = $@"
                var options4= {{
                    chart: {{
                        type: 'bar',
                        height: '250px',
                        foreColor: '#ffffff'
                    }},
                    series: [{options4string}],
                    xaxis: {{
                        categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
                    }},
                    tooltip: {{
                        y: {{
                            formatter: function (val) {{
                                return '₮ ' + val + ' Millions';
                            }}
                        }}
                    }}
                }};
            ";
            string options5 = $@"
                    var options5 = {{
                                chart: {{
                                    height: '250px',
                                    width: '100%',
                                    type: 'treemap',
                                    foreColor: '#ffffff',
                                }},
                                series: [
                                    {{
                                        data: [
                                            {options5string}
                                        ],
                                    }},
                                ]
                            }}
                    ";
            ScriptManager.RegisterStartupScript(this, GetType(), "jsScript1", options1, true);
            //ScriptManager.RegisterStartupScript(this, GetType(), "jsScript2", options2, true);
            ScriptManager.RegisterStartupScript(this, GetType(), "jsScript4", options4, true);
            ScriptManager.RegisterStartupScript(this, GetType(), "jsScript5", options5, true);

            ScriptManager.RegisterStartupScript(this, GetType(), "options2series", $"var options2series= {serializer.Serialize(transactionCurrencyDataResponses.Select(data => ToMillion(double.Parse(data.totalMNT))).ToList())};", true);
            ScriptManager.RegisterStartupScript(this, GetType(), "options2labels", $"var options2labels= {serializer.Serialize(transactionCurrencyDataResponses.Select(data => data.payoutCurr).ToList())};", true);

            ScriptManager.RegisterStartupScript(this, GetType(), "stringListScript2", $"var countryList= {countriesJson};", true);
            ScriptManager.RegisterStartupScript(this, GetType(), "DoubleListScript3", $"var sChargeList= {sChargeJson};", true);
        }
        protected void PopulateMessages()
        {
            var obj = new MessageSettingDao();
            var dt = obj.GetNewsFeeder(GetStatic.GetUser(), GetStatic.GetUserType(), GetStatic.GetCountryId(), GetStatic.GetAgent(), GetStatic.GetBranch());
            if (dt.Rows.Count == 0 || dt == null)
            {
                return;
            }

            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                string msgId = item["msgId"].ToString();
                sb.AppendLine("<li class=\"list-group-item\">");
                sb.AppendLine("<a href=\"javascript:void(0);\" onclick=\"ShowMessage('" + msgId + "')\" data-toggle=\"modal\">" + GetMessageToShow(item["newsFeederMsg"].ToString()) + "</a>");
                sb.AppendLine("<small><i class=\"fa fa-clock-o\"></i>&nbsp;" + item["msgDate"].ToString() + "</small>");
                sb.AppendLine("</li>");
            }
            //messages.InnerHtml = sb.ToString();
        }

        private string GetMessageToShow(string message)
        {
            string pureString = Regex.Replace(message, "<.*?>", String.Empty);
            return pureString.Substring(0, Math.Min(pureString.Length, 40));
        }
        protected void buttonUSD_Click(object sender, EventArgs e)
        {
            ViewState["currency"] = "USD";
            buttonMNT.CssClass = "btn btn-light btn-lg col-12";
            buttonUSD.CssClass = "btn btn-primary btn-lg col-12";

            LoadDashboard();
        }
        protected void buttonMNT_Click(object sender, EventArgs e)
        {
            ViewState["currency"] = "MNT";
            buttonUSD.CssClass = "btn btn-light btn-lg col-12";
            buttonMNT.CssClass = "btn btn-primary btn-lg col-12";

            LoadDashboard();
        }

        protected void Submit(object sender, EventArgs e)
        {
            string message = "";
            ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('" + message + "');", true);
        }
        protected void select()
        {
            var index = Request.Form.GetValues("dropdownMonth");
            foreach (string i in index)
            {
                searchListMonth.Add(i);
            }
            index = Request.Form.GetValues("dropdownYear");

            foreach (string i in index)
            {
                searchListYear.Add(i);
            }

            index = Request.Form.GetValues("dropdownAgent");

            foreach (string i in index)
            {
                searchListAgent.Add(i);
            }
            index = Request.Form.GetValues("dropdownCountry");

            foreach (string i in index)
            {

                searchListCountry.Add(i);
            }
            ViewState["month"] = string.Join(",", searchListMonth);
            ViewState["year"] = string.Join(",", searchListYear);
            ViewState["agent"] = string.Join(",", searchListAgent);
            ViewState["country"] = string.Join(",", searchListCountry);
        }

        protected void OutButton_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "timeline", $"var timeline={ViewState["timeline"].ToString()};", true);
            ViewState["yearOld"] = ViewState["year"];
            ViewState["agentOld"] = ViewState["agent"];
            ViewState["countryOld"] = ViewState["country"];
            ViewState["monthOld"] = ViewState["month"];
            select();
            ViewState["tranType"] = "O";
            inButton.CssClass = "btn btn-light btn-lg col-12";
            outButton.CssClass = "btn btn-primary btn-lg col-12";
            LoadDashboard();
        }
        protected void InButton_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "timeline", $"var timeline={ViewState["timeline"].ToString()};", true);
            select();
            ViewState["tranType"] = "I";
            outButton.CssClass = "btn btn-light btn-lg col-12";
            inButton.CssClass = "btn btn-primary btn-lg col-12";

            LoadDashboard();
        }

        protected void timelineButton_Click(object sender, EventArgs e)
        {
            if (ViewState["timeline"].ToString() == "true")
            {
                ViewState["year"] = ViewState["yearOld"];
                ViewState["agent"] = ViewState["agentOld"];
                ViewState["country"] = ViewState["countryOld"];
                ViewState["month"] = ViewState["monthOld"];
                ScriptManager.RegisterStartupScript(this, GetType(), "timeline", $"var timeline=false;", true);
                ViewState["timeline"] = "false";
                select();
                LoadDashboard();
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "timeline", $"var timeline=true;", true);
                select();
                JsonResponse jsonResponse = new JsonResponse();
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                TransactionDataService serviceObj = new TransactionDataService();
                TransactionDataRequest transactionDataRequest = new TransactionDataRequest
                {
                    flag = "all",
                    tranType = ViewState["tranType"].ToString(),
                    year = ViewState["year"].ToString(),
                    month = ViewState["month"].ToString(),
                    country = ViewState["country"].ToString(),
                    agent = ViewState["agent"].ToString(),
                    currency = ViewState["currency"].ToString(),
                };
                jsonResponse = serviceObj.GetTransactionData(transactionDataRequest);
                var transactionDataResponses = (List<TransactionDataResponse>)jsonResponse.Data;
                double totalSCharge = 0.0;
                foreach (TransactionDataResponse response in transactionDataResponses)
                {
                    if (double.TryParse(response.sCharge, out double sChargeValue))
                    {
                        totalSCharge += sChargeValue;
                    }
                    else
                    {
                        Console.WriteLine("Invalid sCharge value: " + response.sCharge);
                    }
                }

                Console.WriteLine("Total sCharge: " + totalSCharge);
                double totalAmounts = 0.0;
                int rowCount = 0;
                Dictionary<string, double> agentData = new Dictionary<string, double>();
                foreach (TransactionDataResponse response in transactionDataResponses)
                {
                    if (!agentData.ContainsKey(response.agent))
                    {
                        agentData.Add(response.agent, 0.0);
                    }
                    if (double.TryParse(response.total, out double amountValue))
                    {
                        totalAmounts += amountValue;
                    }
                    else
                    {
                        Console.WriteLine("Invalid sCharge value: " + response.total);
                    }
                    rowCount += int.Parse(response.groupRowCount);
                }
                Console.WriteLine("Total sCharge: " + totalAmounts);

                volumeAmount.Text = rowCount.ToString();

                double totalAmountsText = totalAmounts / 1000000; // Convert to millions
                totalAmount.Text = totalAmountsText.ToString("0.##") + "M";

                double totalSChargeText = totalSCharge / 1000000; // Convert to millions
                commissionAmount.Text = totalSChargeText.ToString("0.##") + "M";

                profitAmount.Text = (totalSChargeText / totalAmountsText).ToString("N2") + "%";
                ViewState["timeline"] = "true";

                transactionDataRequest.flag = "timeline";
                jsonResponse = serviceObj.GetTransactionData(transactionDataRequest);
                var timelineDataResponse = (List<TimelineDataResponse>)jsonResponse.Data;
                var options6data = serializer.Serialize(timelineDataResponse.Select(data => new List<(Int64, Int64)> { (Int64.Parse(data.milliseconds), Int64.Parse(data.totalMNT.Split('.')[0].Replace(",",""))) })).Replace("{\"Item1\":","").Replace("}","").Replace("\"Item2\":","");
                ScriptManager.RegisterStartupScript(this, GetType(), "options6", $"var options6data= {options6data};", true);
            }
        }
    }
}