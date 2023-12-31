USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[branchratingdetailNEW]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branchratingdetailNEW](
	[ratingId] [int] IDENTITY(1,1) NOT NULL,
	[branchId] [int] NOT NULL,
	[fromDate] [date] NOT NULL,
	[toDate] [date] NOT NULL,
	[createdBy] [varchar](150) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](150) NULL,
	[modifiedDate] [datetime] NULL,
	[reviewedBy] [varchar](150) NULL,
	[reviewedDate] [datetime] NULL,
	[reviewerComment] [varchar](2500) NULL,
	[approvedBy] [varchar](150) NULL,
	[approvedDate] [datetime] NULL,
	[approverComment] [varchar](2500) NULL,
	[isActive] [varchar](1) NULL,
	[ratingBy] [varchar](150) NULL,
	[ratingDate] [datetime] NULL,
	[ratingComment] [varchar](2500) NULL,
	[reviewedByBranch] [varchar](50) NULL,
	[reviewedDateBranch] [datetime] NULL
) ON [PRIMARY]
GO
