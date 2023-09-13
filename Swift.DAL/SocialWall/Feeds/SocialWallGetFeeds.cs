using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


namespace Swift.DAL.SocialWall.Feeds
{
    public class SocialWallGetFeeds
    {
        public Feeds GetFeeds()
        {
            List<FeedResponse> _responsefeeds = new List<FeedResponse>();
            FeedResponse _responsefeed = new FeedResponse();

            PageInformation _responsepage = new PageInformation();
            _responsepage.before = "test";
            _responsepage.after = "test";
            _responsepage.remaining = "test";

            _responsefeed.id= "test";
            _responsefeed.userId= "test";
            _responsefeed.userDpUrl= "test";
            _responsefeed.firstName= "test";
            _responsefeed.middleName= "test";
            _responsefeed.lastName= "test";
            _responsefeed.nickName= "test";
            _responsefeed.updatedDate= "test";
            _responsefeed.createdDate= "test";
            _responsefeed.agoDate= "test";
            _responsefeed.nativeCountry= "test";
            _responsefeed.accessType= "test";
            _responsefeed.blocked= "test";
            _responsefeed.blockedMessage= "test";
            _responsefeed.reported= "test";
            _responsefeed.reportedMessage= "test";
            _responsefeed.totalLike= "test";
            _responsefeed.totalComment= "test";
            _responsefeed.liked= "test";
            _responsefeed.feedText= "test";
            _responsefeed.feedImageId= "test";
            _responsefeed.feedImage= "test";
            _responsefeeds.Add(_responsefeed);
            _responsefeeds.Add(_responsefeed);


            Feeds feeds = new Feeds();
            
            feeds._feedResponse = _responsefeeds;
            feeds._pageInformation = _responsepage;
            //List<feeds> feeds = new List<feeds>();
            //feeds.Add(feed);
           
            return feeds;
        }
    }
}
