USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[RBAcriteriaCustomer]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RBAcriteriaCustomer](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[parameter] [varchar](50) NOT NULL,
	[criteria] [varchar](50) NOT NULL,
	[score] [int] NOT NULL,
	[createdBy] [varchar](50) NULL,
	[createddate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL
) ON [PRIMARY]
GO
