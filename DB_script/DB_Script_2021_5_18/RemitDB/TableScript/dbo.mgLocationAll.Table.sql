USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[mgLocationAll]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mgLocationAll](
	[AGENTID] [float] NULL,
	[LEGACY] [float] NULL,
	[PARTYNO] [float] NULL,
	[LOCATIONNAME] [nvarchar](255) NULL,
	[CITY] [nvarchar](255) NULL,
	[POSTALCODE] [float] NULL,
	[PHONENO] [nvarchar](255) NULL
) ON [PRIMARY]
GO
