USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_FUND_TRANSFER]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_FUND_TRANSFER](
	[ROW_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SETTINGS_ID] [int] NOT NULL,
	[AMOUNT] [money] NOT NULL,
	[TRAN_DATE] [datetime] NOT NULL,
	[CREATED_BY] [varchar](50) NOT NULL,
	[CREATED_DATE] [datetime] NOT NULL,
	[CURRENCY] [varchar](5) NOT NULL,
	[IS_SUCCESS] [bit] NULL,
	[VOUCHER_NUM] [varchar](20) NULL,
	[ERROR_MSG] [varchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[ROW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
