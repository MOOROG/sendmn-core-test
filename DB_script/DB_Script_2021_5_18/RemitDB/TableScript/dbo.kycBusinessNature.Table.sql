USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[kycBusinessNature]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[kycBusinessNature](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[kycId] [bigint] NULL,
	[institute] [varchar](100) NULL,
	[address] [varchar](150) NULL,
	[designation] [varchar](50) NULL,
	[anualIncome] [money] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
