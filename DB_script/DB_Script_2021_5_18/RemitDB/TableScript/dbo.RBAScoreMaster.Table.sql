USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[RBAScoreMaster]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RBAScoreMaster](
	[TYPE] [varchar](10) NULL,
	[rFrom] [money] NULL,
	[rTo] [money] NULL
) ON [PRIMARY]
GO
