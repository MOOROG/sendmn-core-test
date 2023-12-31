USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[topupQueue]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[topupQueue](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[tranId] [int] NOT NULL,
	[mobileNo] [varchar](15) NULL,
	[TopupAmt] [money] NULL,
	[createdDate] [datetime] NULL,
	[processDate] [datetime] NULL,
	[topupId] [varchar](30) NULL,
	[tranStatus] [varchar](20) NULL,
	[msg] [varchar](500) NULL,
	[membershipId] [varchar](20) NULL,
	[txnDate] [datetime] NULL,
	[tranType] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[tranId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
