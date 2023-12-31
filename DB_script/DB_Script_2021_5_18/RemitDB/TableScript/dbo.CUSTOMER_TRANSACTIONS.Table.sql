USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CUSTOMER_TRANSACTIONS]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CUSTOMER_TRANSACTIONS](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[customerId] [bigint] NOT NULL,
	[tranDate] [datetime] NOT NULL,
	[particulars] [nvarchar](500) NOT NULL,
	[deposit] [money] NOT NULL,
	[withdraw] [money] NOT NULL,
	[refereceId] [bigint] NULL,
	[head] [varchar](40) NOT NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[bankId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
