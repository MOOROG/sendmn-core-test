USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[RBACriteriaTransaction]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RBACriteriaTransaction](
	[rowID] [int] IDENTITY(1,1) NOT NULL,
	[customerRisk] [varchar](50) NOT NULL,
	[amountFrom] [money] NOT NULL,
	[amountTo] [money] NOT NULL,
	[transactionRisk] [varchar](50) NOT NULL,
	[ECDDRequired] [char](1) NULL,
	[complianceHold] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifieddate] [datetime] NULL
) ON [PRIMARY]
GO
