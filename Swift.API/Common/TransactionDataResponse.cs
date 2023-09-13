using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Swift.API.Common
{
    public class TransactionDataResponse
    {
        public string total { get; set; }
        public string sCharge { get; set; }
        public string country { get; set; }
        public string agent { get; set; }
        public string tranYear { get; set; }
        public string tranMonth { get; set; }
        public string groupRowCount { get; set; }
    }
    public class TransactionCurrencyDataResponse
    {
        public string totalMNT { get; set; }
        public string payoutCurr { get; set; }
    }
    public class TransactionDaysDataResponse
    {
        public string totalMNT { get; set; }
        public string tranDay { get; set; }
    }
    public class TransactionYearMonth
    {
        public string year { get; set; }
        public List<double> month { get; set; }
    }
    public class AgentDataResponse
    {
        public string agentName { get; set; }
    }
    public class CountryDataResponse
    {
        public string country { get; set; }
    }
    public class TimelineDataResponse
    {
        public string milliseconds { get; set; }

        public string totalMNT { get; set; }
    }
}
