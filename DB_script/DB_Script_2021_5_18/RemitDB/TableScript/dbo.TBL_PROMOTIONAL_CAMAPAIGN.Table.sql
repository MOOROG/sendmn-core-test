USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_PROMOTIONAL_CAMAPAIGN]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_PROMOTIONAL_CAMAPAIGN](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[PROMOTIONAL_CODE] [varchar](20) NULL,
	[PROMOTIONAL_MSG] [varchar](250) NULL,
	[PROMOTION_TYPE] [int] NULL,
	[PROMOTION_VALUE] [money] NULL,
	[START_DT] [date] NULL,
	[END_DT] [date] NULL,
	[COUNTRY_ID] [int] NULL,
	[PAYMENT_METHOD] [int] NULL,
	[IS_ACTIVE] [bit] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ROW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
