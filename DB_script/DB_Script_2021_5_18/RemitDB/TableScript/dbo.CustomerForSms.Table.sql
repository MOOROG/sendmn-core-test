USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CustomerForSms]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerForSms](
	[a] [varchar](11) NOT NULL,
	[b] [int] NOT NULL,
	[c] [nvarchar](14) NOT NULL,
	[d] [nvarchar](90) NOT NULL,
	[e] [varchar](14) NOT NULL,
	[f] [varchar](14) NOT NULL,
	[g] [varchar](9) NOT NULL,
	[h] [varchar](131) NULL,
	[mobileNo] [varchar](20) NULL,
	[customerId] [bigint] NULL,
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]
GO
