USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempSrilankaAgentList]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempSrilankaAgentList](
	[agentcode] [varchar](7) NOT NULL,
	[bankName] [varchar](35) NOT NULL,
	[branch] [varchar](71) NOT NULL,
	[braddress1] [varchar](46) NOT NULL,
	[add2] [varchar](40) NOT NULL,
	[add3] [varchar](31) NOT NULL,
	[tel1] [varchar](24) NOT NULL,
	[tel2] [varchar](13) NOT NULL,
	[tel3] [varchar](12) NOT NULL,
	[fax] [varchar](15) NOT NULL,
	[email] [varchar](31) NOT NULL,
	[district] [varchar](12) NOT NULL
) ON [PRIMARY]
GO
