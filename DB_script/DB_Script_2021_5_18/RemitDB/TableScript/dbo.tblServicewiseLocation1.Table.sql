USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tblServicewiseLocation1]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblServicewiseLocation1](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[countryId] [int] NOT NULL,
	[serviceTypeId] [int] NULL,
	[location] [nvarchar](100) NOT NULL,
	[partnerLocationId] [varchar](10) NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isActive] [bit] NOT NULL,
	[disabledBy] [varchar](50) NULL,
	[disabledDate] [datetime] NULL,
	[partnerId] [bigint] NULL
) ON [PRIMARY]
GO
