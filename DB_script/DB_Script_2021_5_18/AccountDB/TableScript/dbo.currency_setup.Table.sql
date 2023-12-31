USE [SendMnPro_Account]
GO
/****** Object:  Table [dbo].[currency_setup]    Script Date: 5/18/2021 5:20:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[currency_setup](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[curr_code] [varchar](5) NULL,
	[curr_name] [varchar](50) NULL,
	[curr_desc] [varchar](100) NULL,
	[curr_decimalname] [varchar](20) NULL,
	[decimal_Count] [int] NULL,
	[round_no] [int] NULL,
	[created_date] [datetime] NULL,
	[created_by] [varchar](50) NULL,
	[modified_date] [datetime] NULL,
	[modified_by] [varchar](50) NULL,
	[curr_nepali] [nvarchar](max) NULL,
	[principalCode] [varchar](50) NULL,
	[minRate] [money] NULL,
	[maxRate] [money] NULL,
	[currRoundOff] [char](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
