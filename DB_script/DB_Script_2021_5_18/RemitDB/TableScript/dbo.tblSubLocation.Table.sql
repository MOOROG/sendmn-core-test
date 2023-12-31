USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tblSubLocation]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSubLocation](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[locationId] [bigint] NOT NULL,
	[subLocation] [nvarchar](100) NOT NULL,
	[partnerSubLocationId] [varchar](10) NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NOT NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[disabledBy] [varchar](50) NULL,
	[disabledDate] [datetime] NULL,
	[isActive] [bit] NOT NULL,
	[partnerId] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSubLocation] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblSubLocation] ADD  DEFAULT ((1)) FOR [isActive]
GO
