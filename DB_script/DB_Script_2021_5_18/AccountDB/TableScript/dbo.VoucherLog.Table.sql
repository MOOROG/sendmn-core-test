USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[VoucherLog]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VoucherLog](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[tranId] [bigint] NULL,
	[controlNo] [varchar](25) NULL,
	[Msg] [varchar](500) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
