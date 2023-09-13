using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.SocialWall.Feeds
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
}
