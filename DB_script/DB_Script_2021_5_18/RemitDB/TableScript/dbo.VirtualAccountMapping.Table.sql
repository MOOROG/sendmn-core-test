USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[VirtualAccountMapping]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VirtualAccountMapping](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[bankName] [varchar](150) NULL,
	[virtualAccNumber] [varchar](100) NOT NULL,
	[customerId] [int] NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[old_account_no] [varchar](20) NULL,
	[RandomNumber] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[virtualAccNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
