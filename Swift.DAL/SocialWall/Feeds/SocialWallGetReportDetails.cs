using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.SocialWall.Feeds
{
    public class SocialWallGetReportDetails
    {
        public List<FeedsReportResponse> GetReportDetails()
        {
            FeedsReportResponse _responsefeed = new FeedsReportResponse();
            List<FeedsReportResponse> _responsefeeds = new List<FeedsReportResponse>();
            _responsefeed.id = "test";
            _responsefeed.feedId = "test";
            _responsefeed.reporterId = "test";
            _responsefeed.reporterName = "test";
            _responsefeed.reporterDpUrl = "test";
            _responsefeed.reportMessage = "test";
            _responsefeed.reportDate = "test";
            _responsefeeds.Add(_responsefeed);
            return _responsefeeds;
        }
    }
}
