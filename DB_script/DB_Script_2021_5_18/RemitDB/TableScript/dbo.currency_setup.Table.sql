USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[currency_setup]    Script Date: 5/18/2021 5:16:02 PM ******/
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
 CONSTRAINT [IX_currency_setup] UNIQUE NONCLUSTERED 
(
	[curr_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
