USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranPayCompliance]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranPayCompliance](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[tranId] [bigint] NULL,
	[provider] [bigint] NULL,
	[controlNo] [varchar](50) NULL,
	[pBranch] [int] NULL,
	[receiverName] [varchar](200) NULL,
	[rMemId] [varchar](50) NULL,
	[dob] [datetime] NULL,
	[rIdType] [varchar](100) NULL,
	[rIdNumber] [varchar](100) NULL,
	[rPlaceOfIssue] [varchar](200) NULL,
	[rContactNo] [varchar](100) NULL,
	[rRelationType] [varchar](100) NULL,
	[rRelativeName] [varchar](200) NULL,
	[relWithSender] [varchar](50) NULL,
	[purposeOfRemit] [varchar](500) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedRemarks] [varchar](500) NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[reason] [varchar](500) NULL,
	[bankName] [varchar](100) NULL,
	[branchName] [varchar](100) NULL,
	[chequeNo] [varchar](100) NULL,
	[accountNo] [varchar](100) NULL,
	[alternateMobileNo] [varchar](100) NULL,
	[IdIssuedDate] [datetime] NULL,
	[IdExpiryDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
