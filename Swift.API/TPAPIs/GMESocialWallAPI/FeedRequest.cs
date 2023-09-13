using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.TPAPIs.GMESocialWallAPI
{
    public class FeedRequest
    {
        public string userId { get; set; }
        public string country { get; set; }
        public string onlyReported { get; set; }
        public string before { get; set; }
        public string after { get; set; }
        public string limit { get; set; }
    }
    public class FeedQueryParameters
    {
        public string userId { get; set; }
        public string feedId { get; set; }
        public string page { get; set; }
        public string size { get; set; }
    }
    public class BlockUnblockFeedParameters
    {
        public string feedId { get; set; }
        public string userId { get; set; }
        public string blockedMessage { get; set; }
    }
}
