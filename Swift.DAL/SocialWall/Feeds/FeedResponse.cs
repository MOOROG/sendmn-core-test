using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.SocialWall.Feeds
{
    public class FeedResponse
    {
        public string id { get; set; }
        public string userId { get; set; }
        public string userDpUrl { get; set; }
        public string firstName { get; set; }
        public string middleName { get; set; }
        public string lastName { get; set; }
        public string nickName { get; set; }
        public string updatedDate { get; set; }
        public string createdDate { get; set; }
        public string agoDate { get; set; }
        public string nativeCountry { get; set; }
        public string accessType { get; set; }
        public string blocked { get; set; }
        public string blockedMessage { get; set; }
        public string reported { get; set; }
        public string reportedMessage { get; set; }
        public string totalLike { get; set; }
        public string totalComment { get; set; }
        public string liked { get; set; }
        public string feedText { get; set; }
        public string feedImageId { get; set; }
        public string feedImage { get; set; }
        

    }
}
