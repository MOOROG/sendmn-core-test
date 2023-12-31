USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerMasterMod]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerMasterMod](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[customerId] [int] NULL,
	[customerCardNo] [varchar](100) NULL,
	[firstName] [varchar](100) NULL,
	[middleName] [varchar](100) NULL,
	[lastName] [varchar](100) NULL,
	[country] [varchar](100) NULL,
	[zone] [varchar](100) NULL,
	[district] [varchar](100) NULL,
	[vdcMnc] [varchar](200) NULL,
	[mobile] [varchar](50) NULL,
	[email] [varchar](50) NULL,
	[occupation] [varchar](100) NULL,
	[dobEng] [varchar](50) NULL,
	[dobNep] [varchar](50) NULL,
	[citizenshipNo] [varchar](100) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[isBlackListed] [char](1) NULL,
	[modType] [varchar](50) NULL,
	[relationType] [int] NULL,
	[relativeName] [varchar](200) NULL,
 CONSTRAINT [pk_idx_customerMasterMod] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
