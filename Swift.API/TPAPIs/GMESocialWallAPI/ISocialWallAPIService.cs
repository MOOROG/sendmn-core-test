using Swift.API.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.API.TPAPIs.GMESocialWallAPI
{
    public interface ISocialWallAPIService
    {
        FeedResponse GetFeeds(FeedRequest data, out DbResult dbResult);
        Feeds GetSpecificFeed(FeedQueryParameters data, out DbResult dbResult);
        List<ReportedFeedResponse> GetFeedReportDetails(FeedQueryParameters data,out DbResult dbResult);
        string BlockUnblockFeed(BlockUnblockFeedParameters data,out DbResult dbResult);
    }
}
