USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[kycBankAccount]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[kycBankAccount](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[kycId] [bigint] NULL,
	[bankBranch] [varchar](150) NULL,
	[accountType] [varchar](50) NULL,
	[remarks] [varchar](150) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
