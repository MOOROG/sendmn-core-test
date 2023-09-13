using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.SocialWall.Feeds
{
    public class FeedsReportResponse
    {
        public string id { get; set; }
        public string feedId { get; set; }
        public string reporterId { get; set; }
        public string reporterName { get; set; }
        public string reporterDpUrl { get; set; }
        public string reportMessage { get; set; }
        public string reportDate { get; set; }
        

    }
}
